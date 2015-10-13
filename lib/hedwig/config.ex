defmodule Hedwig.Config do
  @moduledoc """
  Handles configuration for a Hedwig client.

  Configuration is very flexible to allow customization of how clients connect
  to XMPP servers. The different configuration options are as follows:

  * `:server` - Specifies the host to connect to.
    This is inferred by the JID automatically.
  * `:port` - Set the port to connect to. Default is 5222.
  * `:require_tls?` - Specify whether you require TLS. Defaults to `false`.
  * `:preferred_auth_mechanisms` - A list of preferred authentication mechanisms.
  * `:ignore_from_self?` - Filters out messages sent from your JID. Defaults to `true`.
    Set this to `false` if you need to process your own messages.
  """

  alias Hedwig.JID
  alias Hedwig.Client
  alias Hedwig.Transport

  @doc """
  Normalizes client connection details.
  """
  def normalize(client) do
    config = (client[:config] || %{})
    |> Map.put_new(:server, server_from_jid(client.jid))
    |> Map.put_new(:port, 5222)
    |> Map.put_new(:require_tls?, false)
    |> Map.put_new(:use_compression?, false)
    |> Map.put_new(:use_stream_management?, false)
    |> Map.put_new(:preferred_auth_mechanisms, ["PLAIN"])
    |> Map.put_new(:ignore_from_self?, true)
    |> Map.put_new(:transport, :tcp)
    |> Map.put_new(:client, self())
    |> put_transport

    struct(Client, Map.put(client, :config, config))
  end

  @doc """
  Returns the server from the
  """
  def server_from_jid(jid) do
    JID.parse(jid).server
  end

  defp put_transport(config) do
    Map.put(config, :transport, Transport.module(config.transport))
  end
end
