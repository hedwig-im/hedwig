defmodule Hedwig.JID do
  @moduledoc """
  Jabber Identifiers (JIDs) uniquely identify individual entities in an XMPP
  network.

  A JID often resembles an email address with a user@host form, but there's
  a bit more to it. JIDs consist of three main parts:

  A JID can be composed of a local part, a server part, and a resource part.
  The server part is mandatory for all JIDs, and can even stand alone
  (e.g., as the address for a server).

  The combination of a local (user) part and a server is called a "bare JID",
  and it is used to identitfy a particular account on a server.

  A JID that includes a resource is called a "full JID", and it is used to
  identify a particular client connection (i.e., a specific connection for the
  associated "bare JID" account).
  """

  alias Hedwig.JID

  @type t :: %__MODULE__{}
  defstruct user: "", server: "", resource: ""


  @doc """
  Returns a string representation from a JID struct.

  ## Examples
      iex> Hedwig.JID.to_string(%Hedwig.JID{user: "romeo", server: "capulet.lit", resource: "chamber"})
      "romeo@capulet.lit/chamber"

      iex> Hedwig.JID.to_string(%Hedwig.JID{user: "romeo", server: "capulet.lit"})
      "romeo@capulet.lit"

      iex> Hedwig.JID.to_string(%Hedwig.JID{server: "capulet.lit"})
      "capulet.lit"
  """
  @spec to_string(jid :: JID.t) :: binary
  def to_string(%JID{user: "", server: server, resource: ""}), do: server
  def to_string(%JID{user: user, server: server, resource: ""}) do
    user <> "@" <> server
  end
  def to_string(%JID{user: user, server: server, resource: resource}) do
    user <> "@" <> server <> "/" <> resource
  end


  @doc """
  Returns a binary JID without a resource.

  ## Examples
      iex> Hedwig.JID.bare(%Hedwig.JID{user: "romeo", server: "capulet.lit", resource: "chamber"})
      "romeo@capulet.lit"

      iex> Hedwig.JID.bare("romeo@capulet.lit/chamber")
      "romeo@capulet.lit"
  """
  @spec bare(jid :: binary | JID.t) :: binary
  def bare(jid) when is_binary(jid), do: parse(jid) |> bare
  def bare(%JID{} = jid), do: JID.to_string(%JID{jid | resource: ""})


  @doc """
  Parses a binary string JID into a JID struct.

  ## Examples
      iex> Hedwig.JID.parse("romeo@capulet.lit")
      %Hedwig.JID{user: "romeo", server: "capulet.lit", resource: "chamber"}

      iex> Hedwig.JID.bare("romeo@capulet.lit")
      %Hedwig.JID{user: "romeo", server: "capulet.lit", resource: ""}
  """
  @spec parse(jid :: binary) :: JID.t
  def parse(string) do
    case String.split(string, ["@", "/"], parts: 3) do
      [user, server, resource] ->
        %JID{user: user, server: server, resource: resource}
      [user, server] ->
        %JID{user: user, server: server}
      [server] ->
        %JID{server: server}
    end
  end
end

