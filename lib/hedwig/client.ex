defmodule Hedwig.Client do
  @moduledoc """
  XMPP Client
  """

  use GenServer
  alias Hedwig.Stanza

  defmodule State do
    defstruct event_handlers: [],
              server: "",
              port: 5222,
              socket: nil,
              connected?: false,
              authenticated?: false,
              jid: "",
              pass: "",
              nick: "",
              rooms: [],
              parser: nil
  end

  # Public API

  @doc """
  Connect to the XMPP server.
  """
  def connect(pid) do
    GenServer.call pid, :connect
  end

  def start_stream(pid) do
    GenServer.call pid, :start_stream
  end

  def start_tls(pid) do
    GenServer.call pid, :start_tls
  end

  def send(pid, data) do
    GenServer.call pid, {:send, data}
  end

  # GenServer API

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, options, [])
  end

  @spec init(list(any) | []) :: {:ok, State.t}
  def init(options \\ []) do
    server = Keyword.get(options, :server, "localhost")
    port   = Keyword.get(options, :port, 5222)
    {:ok, parser} = :exml_stream.new_parser

    {:ok, %State{server: server, port: port, parser: parser}}
  end

  def handle_call(:connect, _from, %State{server: server, port: port} = state) do
    if state.socket != nil, do: :gen_tcp.close(state.socket)

    case Hedwig.Socket.connect(server, port) do
      {:ok, socket} ->
        {:reply, :ok, %State{state| socket: socket, connected?: true} }
      error ->
        {:reply, {:error, error}, state}
    end
  end

  def handle_call(:start_stream, _from, state) do
    stanza = Stanza.start_stream state.server
    Hedwig.Socket.send(state.socket, stanza)
    {:reply, :ok, state}
  end

  def handle_call(:start_tls, _from, state) do
    Hedwig.Socket.send state.socket, Stanza.start_tls
    {:reply, :ok, state}
  end

  def handle_call({:send, data}, _from, state) do
    Hedwig.Socket.send state.socket, data
    {:reply, :ok, state}
  end

  def handle_info({:tcp, socket, data}, state) do
    {:ok, parser, packet} = :exml_stream.parse(state.parser, data)
    IO.puts "====================== PACKET =============================="
    IO.inspect packet
    IO.puts "==================== END PACKET ============================"
    {:noreply, %{state| parser: parser}}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    IO.puts "Socket closed"
    {:noreply, %{state| parser: nil, socket: nil, connected?: false}}
  end

  def handle_info({_msg, state}) do
    {:noreply, state}
  end
end
