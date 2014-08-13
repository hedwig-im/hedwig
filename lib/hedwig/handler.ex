defmodule Hedwig.Handler do
  use Hedwig.XML

  alias Hedwig.JID
  alias Hedwig.Client

  defmacro __using__(_opts) do
    quote do
      use GenEvent
      use Hedwig.XML

      alias Hedwig.JID
      alias Hedwig.Client
      alias Hedwig.Stanzas.IQ
      alias Hedwig.Stanzas.Message
      alias Hedwig.Stanzas.Presence

      require Logger
      import unquote __MODULE__
    end
  end

  @doc """
  It's best to ignore messages you receive back from yourself to avoid
  recursive handling.
  """
  def from_self?(%JID{resource: resource} = from, client) do
    JID.bare(from) == JID.parse(client.jid) or resource == client.nickname
  end

  @doc """
  If the resource is blank, the message is from the MUC room and not a user.

  This happens when you join a room and the room has a topic set. The room
  will send you a message stanza to notify you of the room topic.
  """
  def from_muc_room?(%JID{resource: resource}) do
    resource == ""
  end

  @doc """
  Send a reply via the client pid.
  """
  def reply(client, message, body) do
    Client.reply(client.pid, Stanza.message(message.type, JID.bare(message.from), body))
  end
end
