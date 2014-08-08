defmodule Hedwig.Client do
  @moduledoc """
  XMPP Client
  """

  use GenServer
  use Hedwig.XML

  require Logger

  alias Hedwig.JID
  alias Hedwig.Conn
  alias Hedwig.Client
  alias Hedwig.Transport

  @type t :: %__MODULE__{}
  @derive [Access, Enumerable]
  defstruct jid: "",
            nickname: "",
            resource: "",
            conn: nil,
            config: %{},
            rooms: [],
            scripts: [],
            event_manager: nil

  @spec start_link(config :: %{}) :: {:ok, client :: pid}
  def start_link(config) do
    {:ok, client} = GenServer.start_link(__MODULE__, config)
    client |> start_event_manager |> connect
    {:ok, client}
  end

  def start_event_manager(pid) do
    GenServer.call(pid, :start_event_manager)
    pid
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

  def handle_stanza(pid, stanza) do
    GenServer.cast(pid, {:handle_stanza, stanza})
  end

  def reply(pid, stanza) do
    GenServer.cast(pid, {:reply, stanza})
  end

  @doc """
  Returns the client config for the given JID.
  """
  def client_for(jid) do
    Enum.find Application.get_env(:hedwig, :clients), fn client ->
      client.jid == jid
    end
  end

  def configure_client(client) do
    %JID{server: server} = JID.parse(client.jid)

    config = if client[:config], do: client[:config], else: %{}
    |> Map.put_new(:server, server)
    |> Map.put_new(:port, 5222)
    |> Map.put_new(:require_tls?, false)
    |> Map.put_new(:use_compression?, false)
    |> Map.put_new(:use_stream_management?, false)
    |> Map.put_new(:transport, :tcp)
    |> Map.put_new(:client, self)

    config = Map.put(config, :transport, Transport.module(config.transport))
    client = Map.put(client, :config, config) |> Map.to_list

    struct(Client, client)
  end

  def init(config) do
    {:ok, configure_client(config)}
  end

  def handle_call(:start_event_manager, _from, client) do
    {:ok, manager} = GenEvent.start_link

    client_opts = client
    |> Map.take([:jid, :resource, :nickname])
    |> Map.put(:pid, self)

    for {script, opts} <- client.scripts do
      GenEvent.add_handler(manager, script, opts, link: true)
      opts = Map.merge(%{client: client_opts}, opts)
    end

    new_state = %Client{client | event_manager: manager}
    {:reply, new_state, new_state}
  end

  def handle_cast(:connect, %Client{config: config} = client) do
    conn = spawn fn -> Conn.start(config) end
    {:noreply, %Client{client | conn: conn}}
  end

  def handle_cast({:handle_stanza, stanza}, %Client{event_manager: pid} = client) do
    GenEvent.notify(pid, stanza)
    {:noreply, client}
  end

  def handle_cast({:reply, stanza}, %Client{conn: conn} = client) do
    Kernel.send(conn, {:send, stanza})
    {:noreply, client}
  end

  def handle_call(:get, _from, client) do
    {:reply, client, client}
  end
  def handle_call({:get, key}, _from, client) do
    {:reply, Map.get(client, key), client}
  end
end
