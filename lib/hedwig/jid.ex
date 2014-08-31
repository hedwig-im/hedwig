defmodule Hedwig.JID do

  alias Hedwig.JID

  @type t :: %__MODULE__{}
  defstruct user: "", server: "", resource: ""

  @spec to_string(jid :: JID.t) :: binary
  def to_string(%JID{user: user, server: server, resource: ""}) do
    user <> "@" <> server
  end
  def to_string(%JID{user: user, server: server, resource: resource}) do
    user <> "@" <> server <> "/" <> resource
  end

  def bare(%JID{} = jid) do
    JID.to_string(%JID{jid | resource: ""})
  end

  @spec parse(jid :: binary) :: JID.t
  def parse(string) do
    case String.split(string, ["@", "/"]) do
      [user, server, resource] ->
        %JID{user: user, server: server, resource: resource}
      [user, server] ->
        %JID{user: user, server: server}
    end
  end
end
