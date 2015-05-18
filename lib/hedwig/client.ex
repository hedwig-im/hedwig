defmodule Hedwig.Client do
  @moduledoc """
  XMPP Client
  """

  use GenServer
  use Hedwig.XML

  require Logger

  alias Hedwig.JID
  alias Hedwig.Conn
  alias Hedwig.Config
  alias Hedwig.Client
  alias Hedwig.Handler
  alias Hedwig.Helpers

  @type t :: %__MODULE__{}
  defstruct [
    jid: "",
    password: "",
    nickname: "",
    resource: "",
    conn: nil,
    config: %{},
    rooms: [],
    handlers: [],
    event_manager: nil
  ]

  @spec start_link(config :: %{}) :: {:ok, client :: pid}
  def start_link(config) do
    {:ok, client} = GenServer.start_link(__MODULE__, config)
    client
    |> start_event_manager
    |> start_event_handlers
    |> connect
    {:ok, client}
  end

  @doc """
  Starts a GenEvent manager.
  """
  def start_event_manager(pid) do
    GenServer.call(pid, :start_event_manager)
    pid
  end

  @doc """
  Start all GenEvent handlers for the client.
  """
  def start_event_handlers(pid) do
    GenServer.call(pid, :start_event_handlers)
    pid
  end

  @doc """
  Adds a monitored handler.
  """
  def add_mon_handler(client, {handler, opts}) do
    :ok = GenEvent.add_mon_handler(client.event_manager, handler, opts)
  end

  @doc """
  Starts the connection process.
  """
  def connect(pid), do: GenServer.cast(pid, :connect)

  @doc """
  Returns the client configuration.
  """
  def get(pid), do: GenServer.call(pid, :get)
  def get(pid, key), do: GenServer.call(pid, {:get, key})

  @doc """
  Notifies the event manager of an incoming stanza.
  """
  def handle_stanza(pid, stanza) do
    stanza = %{stanza | client: pid}
    GenServer.cast(pid, {:handle_stanza, stanza})
  end

  def reply(pid, stanza) do
    GenServer.cast(pid, {:reply, stanza})
  end

  @doc """
  Returns the client config for the given JID.
  """
  def client_for(jid) do
    Enum.find Application.get_env(:hedwig, :clients), &(&1.jid == jid)
  end


  def init(config) do
    {:ok, Config.normalize(config)}
  end

  def handle_call(:start_event_manager, _from, client) do
    {:ok, manager} = GenEvent.start_link
    new_state = %Client{client | event_manager: manager}
    {:reply, new_state, new_state}
  end

  def handle_call(:start_event_handlers, _from, client) do
    for {handler, opts} <- client.handlers do
      opts = Handler.merge_client_opts(client, opts)
      add_mon_handler(client, {handler, opts})
    end
    {:reply, client, client}
  end

  def handle_call(:get, _from, client) do
    {:reply, client, client}
  end
  def handle_call({:get, key}, _from, client) do
    {:reply, Map.get(client, key), client}
  end

  def handle_cast(:connect, %Client{config: config} = client) do
    conn = spawn_link fn -> Conn.start(config) end
    {:noreply, %Client{client | conn: conn}}
  end

  def handle_cast({:handle_stanza, stanza}, %Client{event_manager: pid, config: %{ignore_from_self?: ignore}} = client) do
    Logger.info fn -> "Incoming stanza: #{inspect stanza}" end

    drop = Helpers.from_self?(stanza.from, client) && ignore

    unless drop do
      GenEvent.notify(pid, stanza)
    end

    {:noreply, client}
  end

  def handle_cast({:reply, stanza}, %Client{conn: conn} = client) do
    Kernel.send(conn, {:send, stanza})
    {:noreply, client}
  end

  def handle_info({:gen_event_EXIT, handler, _reason}, client) do
    opts = Handler.get_opts(client, handler)
    Client.add_mon_handler(client, {handler, opts})
    {:noreply, client}
  end

  def handle_info({:stop, reason}, %Client{conn: conn} = client) do
    Kernel.send(conn, {:send, Hedwig.Stanza.presence("unavailable")})
    Kernel.send(conn, {:send, Hedwig.Stanza.end_stream})
    {:stop, reason, client}
  end

  def handle_info(msg, client) do
    Logger.info fn ->
      "Unexpected message received: #{inspect msg}"
    end
    {:noreply, client}
  end
end

