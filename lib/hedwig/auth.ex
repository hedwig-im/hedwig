defmodule Hedwig.Auth do

  use Hedwig.XML

  alias Hedwig.JID
  alias Hedwig.Conn
  alias Hedwig.Client
  alias Hedwig.Stanza

  defmodule Error do
    defexception [:message]

    def exception(mechanism) do
      msg = "Failed to authenticate using mechanism: #{inspect mechanism}"
      %Hedwig.Auth.Error{message: msg}
    end
  end

  def authenticate!(conn) do
    preferred  = conn.config.preferred_auth_mechanisms
    mechanisms = conn.features.mechanisms
    preferred_mechanism(preferred, mechanisms) |> do_authenticate(conn)
  end

  defp do_authenticate(mechanism, conn) do
    authenticate_with(mechanism, conn)
    case success?(conn) do
      {:ok, conn} -> conn
      {:error, conn} -> raise Hedwig.Auth.Error, mechanism
    end
  end

  defp authenticate_with("PLAIN", %Conn{transport: mod} = conn) do
    [username, password] = get_client_credentials(conn)
    payload = <<0>> <> username <> <<0>> <> password
    mod.send conn, Stanza.auth("PLAIN", Stanza.base64_cdata(payload))
  end

  defp authenticate_with("DIGEST-MD5", %Conn{transport: _mod} = _conn) do
    raise "Not implemented"
  end

  defp authenticate_with("SCRAM-SHA-1", %Conn{transport: _mod} = _conn) do
    raise "Not implemented"
  end

  defp authenticate_with("ANONYMOUS", %Conn{transport: mod} = conn) do
    mod.send conn, Stanza.auth("ANONYMOUS")
  end

  defp authenticate_with("EXTERNAL", _conn) do
    raise "Not implemented"
  end

  defp success?(conn) do
    stanza = Conn.recv(conn, :wait_for_auth_reply)
    case xmlel(stanza, :name) do
      "success" -> {:ok, conn}
      "failure" -> {:error, conn}
    end
  end

  defp get_client_credentials(%Conn{client: pid}) do
    jid = Client.get(pid, :jid)
    [JID.parse(jid).user, Client.get(pid, :password)]
  end

  defp preferred_mechanism([], _), do: "PLAIN"
  defp preferred_mechanism([h|t], mechanisms) do
    case Enum.member?(mechanisms, h) do
      true  -> h
      false -> preferred_mechanism(t, mechanisms)
    end
  end
end

