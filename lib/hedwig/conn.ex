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

  @type t :: %__MODULE__{
              transport: module,
              pid: pid,
              socket: port,
              ssl?: boolean,
              compress?: boolean,
              features: Features.t}

  defstruct transport: nil,
            pid: nil,
            socket: nil,
            ssl?: false,
            compress?: false,
            features: %Features{}

  @timeout 1000

  def start(%Client{} = client) do
    client
    |> connect
    |> start_stream
    |> negotiate_features
    |> start_tls
    |> negotiate_auth_mechanisms
    |> authenticate
    |> bind
    |> session
    |> send_presence
    |> join_rooms
    |> await
  end

  def connect(%Client{} = client) do
    mod = convert_transport(client[:config][:transport])
    {:ok, conn} = mod.connect(client[:config])
    {conn, client}
  end

  def start_stream({%Conn{transport: mod} = conn, client}) do
    mod.send(conn, Stanza.start_stream(client[:config][:server]))
    read_from_socket(conn, :starting_stream)
    {conn, client}
  end

  def negotiate_features({conn, client}) do
    stream_features = read_from_socket(conn, :wait_for_features)
    features = parse_stream_features(stream_features)
    {%Conn{conn | features: features}, client}
  end

  def start_tls({%Conn{transport: mod, features: features} = conn, client}) do
    case features.tls? do
      true ->
        mod.send(conn, Stanza.start_tls)
        read_from_socket(conn, :wait_for_proceed)
        mod.upgrade_to_tls({conn, client})
      false ->
        {conn, client}
    end
  end

  def negotiate_auth_mechanisms({conn, client}) do
    stream_features = read_from_socket(conn, :wait_for_features)
    mechanisms = supported_auth_mechanisms(stream_features)
    {%Conn{conn | features: %Features{mechanisms: mechanisms}}, client}
  end

  def authenticate({conn, client}) do
    Auth.authenticate(:plain, conn, client)
    reset_parser(conn)
    start_stream({conn, client})
    {conn, client}
  end

  def bind({%Conn{transport: mod} = conn, client}) do
    mod.send conn, Stanza.bind(client.resource)
    read_from_socket(conn, :wait_for_bind_result)
    {conn, client}
  end

  def session({%Conn{transport: mod} = conn, client}) do
    mod.send conn, Stanza.session
    read_from_socket(conn, :wait_for_bind_result)
    {conn, client}
  end

  def send_presence({%Conn{transport: mod} = conn, client}) do
    mod.send conn, Stanza.presence
    read_from_socket(conn, :wait_for_bind_result)
    Logger.info IO.ANSI.escape "%{green}#{client.jid} successfully connected."
    {conn, client}
  end

  def join_rooms({%Conn{transport: mod} = conn, %Client{rooms: rooms} = client}) do
    for room <- rooms do
      mod.send(conn, Stanza.join(room, client.nickname))
    end
    {conn, client}
  end

  def await({conn, client}) do
    receive do
      {:stanza, conn, stanza} ->
        Logger.info IO.ANSI.escape "%{green}#{inspect stanza}\n"
        await({conn, client})
      after 10000 ->
        :ok
        await({conn, client})
    end
  end

  def reset_parser(%Conn{transport: mod} = conn) do
    mod.reset_parser(conn)
  end

  defp read_from_socket(_conn, message) do
    receive do
      {:stanza, _conn, stanza} ->
        stanza
    after @timeout ->
      throw {:timeout, message}
    end
  end

  defp parse_stream_features(features) do
    %Features{
      compression?: supports?(features, "compression"),
      tls?: supports?(features, "starttls"),
      stream_management?: supports?(features, "sm")
    }
  end

  defp supports?(features, "compression") do
    case :exml_query.subelement(features, "compression") do
      xml when Record.record?(xml, :xmlel) ->
        methods = xmlel(xml, :children)
        for method <- methods, into: [], do: :exml_query.cdata(method)
      _ -> false
    end
  end
  defp supports?(features, feature) do
    case :exml_query.subelement(features, feature) do
      :undefined -> false
      _          -> true
    end
  end

  defp supported_auth_mechanisms(features) do
    case :exml_query.subelement(features, "mechanisms") do
      xml when Record.record?(xml, :xmlel) ->
        mechanisms = xmlel(xml, :children)
        for mechanism <- mechanisms, into: [], do: :exml_query.cdata(mechanism)
      [] -> []
    end
  end

  defp convert_transport(transport) do
    case Atom.to_string(transport) do
      "Elixir." <> _ -> transport
      reference -> Module.concat(Hedwig.Transports, String.upcase(reference))
    end
  end
end
