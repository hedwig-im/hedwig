defmodule Hedwig.Helpers do
  @moduledoc """
  Provides utility functions.
  """

  alias Hedwig.JID

  @doc """
  It's best to ignore messages you receive back from yourself to avoid
  recursive handling.
  """
  def from_self?(%JID{resource: resource} = from, client) do
    JID.bare(from) == JID.parse(client.jid) or resource == client.nickname
  end
  def from_self?(_, _), do: true

  @doc """
  If the resource is blank, the message is from the MUC room and not a user.

  This happens when you join a room and the room has a topic set. The room
  will send you a message stanza to notify you of the room topic.
  """
  def from_muc_room?(%JID{resource: resource}) do
    resource == ""
  end
  def from_muc_room?(_), do: true
end
