defmodule Hedwig.Config do
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

