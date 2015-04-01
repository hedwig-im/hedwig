defmodule Hedwig.Conn do
  @moduledoc """
  The Hedwing connection.

  This module defines a struct and the main functions for working
  with XMPP connections.
  """

  use Hedwig.XML

  require Logger

  alias Hedwig.Conn
  alias Hedwig.Auth
  alias Hedwig.Stanza
  alias Hedwig.Client
  alias Hedwig.Conn.Features

  @type config :: %{}

  @type t :: %__MODULE__{
    transport: module,
    config: config,
    pid: pid,
    client: pid,
    socket: port,
    ssl?: boolean,
    compress?: boolean,
    features: Features.t
  }

  defstruct [
    transport: nil,
    config: %{},
    pid: nil,
    client: nil,
    socket: nil,
    ssl?: false,
    compress?: false,
    features: %Features{}
  ]

  @timeout 1000

  @doc """
  Starts a connection process.
  """
  @spec start(config :: config) :: no_return
  def start(config) do
    config
    |> connect
    |> start_stream
    |> negotiate_features
    |> start_tls
    |> authenticate
    |> bind
    |> session
    |> send_presence
    |> join_rooms
    |> await
  end

  @spec connect(config :: config) :: t
  def connect(%{transport: mod} = config) do
    {:ok, conn} = mod.start(config)
    wait_for_socket(conn)
  end

  def start_stream(%Conn{transport: mod, config: config} = conn) do
    mod.send(conn, Stanza.start_stream(config.server))
    recv(conn, :starting_stream)
    conn
  end

  def negotiate_features(conn) do
    stream_features = recv(conn, :wait_for_features)
    features = Features.parse_stream_features(stream_features)
    %Conn{conn | features: features}
  end

  def start_tls(%Conn{transport: mod, features: features} = conn) do
    case features.tls? do
      true ->
        mod.send(conn, Stanza.start_tls)
        recv(conn, :wait_for_proceed)

        conn
        |> mod.upgrade_to_tls()
        |> negotiate_features()
      false ->
        conn
    end
  end

  def authenticate(conn) do
    Auth.authenticate!(conn)
    reset_parser(conn)
    start_stream(conn)
    conn
  end

  def bind(%Conn{transport: mod, client: client} = conn) do
    mod.send conn, Stanza.bind(Client.get(client, :resource))
    recv(conn, :wait_for_bind_result)
    conn
  end

  def session(%Conn{transport: mod} = conn) do
    mod.send conn, Stanza.session
    recv(conn, :wait_for_bind_result)
    conn
  end

  def send_presence(%Conn{transport: mod, client: pid} = conn) do
    jid = Client.get(pid, :jid)
    mod.send conn, Stanza.presence
    recv(conn, :wait_for_bind_result)
    Logger.info fn -> "#{jid} successfully connected." end
    conn
  end

  def join_rooms(%Conn{transport: mod, client: pid} = conn) do
    client = Client.get(pid)
    for room <- client.rooms do
      mod.send(conn, Stanza.join(room, client.nickname))
    end
    conn
  end

  def await(%Conn{transport: mod, client: client} = conn) do
    receive do
      {:stanza, conn, stanza} ->
        Client.handle_stanza(client, Stanza.Parser.parse(stanza))
        Conn.await(conn)
      {:send, stanza} ->
        mod.send(conn, stanza)
        Conn.await(conn)
    after 10000 ->
      Conn.await(conn)
    end
  end

  def reset_parser(%Conn{transport: mod} = conn) do
    mod.reset_parser(conn)
  end

  def recv(_conn, message) do
    receive do
      {:stanza, _conn, stanza} ->
        stanza
    after @timeout ->
      throw {:timeout, message}
    end
  end

  defp wait_for_socket(%Conn{} = conn) do
    Logger.info fn -> "Waiting for socket" end
    receive do
      {:connected, socket} ->
        %Conn{conn | socket: socket}
      _ ->
        wait_for_socket(conn)
    end
  end
end
