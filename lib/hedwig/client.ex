defmodule Hedwig.Client do
  @moduledoc """
  XMPP Client
  """

  use GenServer

  require Logger

  alias Hedwig.JID
  alias Hedwig.Conn
  alias Hedwig.Client
  alias Hedwig.Stanza

  @type t :: %__MODULE__{}
  @derive [Access, Enumerable]
  defstruct jid: "",
            nickname: "",
            resource: "",
            conn: %Conn{},
            config: [],
            rooms: [],
            event_handlers: []

  @spec start_link(client :: list) :: {:ok, pid}
  def start_link(client) do
    GenServer.start_link(__MODULE__, to_struct(client), [])
  end

  @doc """
  Returns the client config for the given JID.
  """
  def client_for(jid) do
    client = Enum.find Application.get_env(:hedwig, :clients), fn client ->
      client.jid == jid
    end
  end

  def normalize_config(client) do
    %JID{server: server} = JID.parse(client.jid)

    config = if client[:config], do: client[:config], else: []
    |> Keyword.put_new(:server, server)
    |> Keyword.put_new(:port, 5222)
    |> Keyword.put_new(:require_tls?, false)
    |> Keyword.put_new(:use_compression?, false)
    |> Keyword.put_new(:use_stream_management?, false)
    |> Keyword.put_new(:transport, :tcp)

    Map.put(client, :config, config)
  end

  @doc """
  Converts a map to a Client struct.
  """
  def to_struct(client) do
    client = normalize_config(client)
    struct(Client, Map.to_list(client))
  end

  def init(client) do
    conn = spawn_link(Conn, :start, [client])
    {:ok, %Client{conn: conn}}
  end
end
