defmodule Hedwig.Jid do

  alias Hedwid.Jid

  defstruct user: "", server: "", resource: ""

  def to_binary(%Jid{user: user, server: server, resource: ""}) do
    user <> "@" <> server
  end
  def to_binary(%{user: user, server: server, resource: resource}) do
    user <> "@" <> server <> "/" <> resource
  end

  def to_jid(string) do
    case String.split(string, ["@", "/"]) do
      [user, server, resource] ->
        %Jid{user: user, server: server, resource: resource}
      [user, server] ->
        %Jid{user: user, server: server}
    end
  end
end
