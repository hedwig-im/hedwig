defmodule Hedwig.Transports.TCP do
  @moduledoc """
  XMPP Socket connection
  """

  use Hedwig.Transport

  alias Hedwig.Conn
  alias Hedwig.Stanza

  @type t :: %__MODULE__{
    transport: module,
    pid: pid,
    config: %{},
    client: pid,
    socket: port,
    parser: term,
    ssl?: boolean,
    compress?: boolean
  }

  defstruct [
    transport: __MODULE__,
    pid: nil,
    config: %{},
    client: nil,
    socket: nil,
    parser: nil,
    ssl?: false,
    compress?: false
  ]

  @doc """
  Open a socket connection to the XMPP server.
  """
  def start(conn) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [conn, self()])
    {:ok, GenServer.call(pid, :get_transport)}
  end

  @doc """
  Send data over the socket.
  """
  def send(%Conn{socket: socket} = conn, stanza) do
    Logger.info fn -> "Outgoing stanza: #{inspect stanza}" end

    stanza = Stanza.to_xml(stanza)
    case conn.ssl? do
      true  -> :ssl.send socket, stanza
      false -> :gen_tcp.send socket, stanza
    end
  end

  @doc """
  Checks if the connection is alive.
  """
  def connected?(%Conn{socket: socket}) do
    Process.alive?(socket)
  end

  @doc """
  Upgrades the connection to TLS.
  """
  def upgrade_to_tls(%Conn{pid: pid} = conn) do
    GenServer.call(pid, {:upgrade_to_tls, []})
    conn = get_transport(conn)
    Conn.start_stream(conn)
  end

  def use_zlib(%Conn{} = conn) do
    conn
  end

  def get_transport(%Conn{pid: pid}) do
    GenServer.call(pid, :get_transport)
  end

  def reset_parser(%Conn{pid: pid}) do
    GenServer.cast(pid, :reset_parser)
  end

  def init([config, connection_pid]) do
    Kernel.send(self(), :connect)
    {:ok, parser} = :exml_stream.new_parser
    state = %TCP{
      pid: connection_pid,
      config: config,
      client: config.client,
      parser: parser
    }
    {:ok, state}
  end

  def handle_call(:get_transport, _from, state) do
    {:reply, transport(state), state}
  end

  def handle_call({:upgrade_to_tls, opts}, _from, state) do
    opts = Keyword.merge([reuse_sessions: true], opts)
    {:ok, socket} = :ssl.connect(state.socket, opts)
    {:ok, parser} = :exml_stream.new_parser
    {:reply, socket, %TCP{state | socket: socket, parser: parser, ssl?: true}}
  end

  def handle_cast(:reset_parser, %TCP{parser: parser} = state) do
    {:ok, parser} = :exml_stream.reset_parser(parser)
    {:noreply, %TCP{state | parser: parser}}
  end

  def handle_info(:connect, state) do
    host = String.to_char_list(state.config.server)
    port = state.config.port
    case :gen_tcp.connect(host, port, [:binary, active: :once]) do
      {:ok, socket} ->
        Kernel.send(state.pid, {:connected, socket})
        {:noreply, %TCP{state | socket: socket}}
      _ ->
        Kernel.send(self(), :connect)
        {:noreply, state}
    end
  end

  def handle_info({:tcp, socket, data}, state) do
    :inet.setopts(socket, active: :once)
    handle_data(socket, data, state)
  end
  def handle_info({:ssl, socket, data}, state) do
    :ssl.setopts(socket, active: :once)
    handle_data(socket, data, state)
  end
  def handle_info({:tcp_closed, _socket}, state) do
    Logger.error "Socket closed"
    {:stop, :shutdown, state}
  end

  def handle_info({:ssl_closed, _socket}, state) do
    Logger.error "Socket closed"
    {:stop, :shutdown, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp handle_data(_socket, data, state) do
    {:ok, parser, stanzas} = :exml_stream.parse(state.parser, data)
    Logger.debug fn -> "Incoming stanza: #{inspect data}" end
    new_state = %TCP{state | parser: parser}
    for stanza <- stanzas do
      Kernel.send(state.pid, {:stanza, transport(new_state), stanza})
    end
    {:noreply, new_state}
  end

  defp transport(%TCP{} = state) do
    %Conn{
      transport: __MODULE__,
      pid:       self(),
      config:    state.config,
      client:    state.client,
      socket:    state.socket,
      ssl?:      state.ssl?,
      compress?: state.compress?
    }
  end
end
