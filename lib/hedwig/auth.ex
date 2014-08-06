defmodule Hedwig.Auth do

  use Hedwig.XML

  alias Hedwig.JID
  alias Hedwig.Conn
  alias Hedwig.Client
  alias Hedwig.Stanza

  def authenticate(:plain, %Conn{transport: mod, client: pid} = conn) do
    jid = Client.get(pid, :jid)
    username = JID.parse(jid).user
    password = Client.client_for(jid).password
    payload = <<0>> <> username <> <<0>> <> password
    mod.send conn, Stanza.auth("PLAIN", payload)
    success?(conn)
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

  def success?(conn) do
    stanza = Conn.recv(conn, :wait_for_auth_reply)
    case xmlel(stanza, :name) do
      "success" ->
        conn
      "failure" ->
        throw {:auth_failed, conn}
    end
  end
end
