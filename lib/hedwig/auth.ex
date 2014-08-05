defmodule Hedwig.Auth do

  use Hedwig.XML

  alias Hedwig.JID
  alias Hedwig.Conn
  alias Hedwig.Client
  alias Hedwig.Stanza

  def authenticate(:plain, %Conn{transport: mod} = conn, client) do
    username = JID.parse(client.jid).user
    password = Client.client_for(client.jid).password
    payload = <<0>> <> username <> <<0>> <> password
    mod.send conn, Stanza.auth("PLAIN", payload)
    success?(conn, client)
  end

  def authenticate(:digest_md5, _conn, _client) do
    raise "Not implemented"
  end

  def authenticate(:sasl_scram_sha1, _conn, _client) do
    raise "Not implemented"
  end

  def authenticate(:sasl_anon, _conn, _client) do
    raise "Not implemented"
  end

  def authenticate(:sasl_external, _conn, _client) do
    raise "Not implemented"
  end

  def success?(conn, client) do
    stanza = Conn.recv(conn, :wait_for_auth_reply)
    case xmlel(stanza, :name) do
      "success" ->
        {conn, client}
      "failure" ->
        throw {:auth_failed, conn, client}
    end
  end
end
