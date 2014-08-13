defmodule Hedwig.Handlers.Echo do
  @moduledoc """
  A completely useless echo script.

  This script simply echoes the same message back.
  """
  use Hedwig.Handler

  def handle_event(%Message{from: from, delayed?: false} = message, %{client: client} = opts) do
    if not from_self?(from, client) and not from_muc_room?(from) do
      to = JID.bare(from)
      Client.reply(client.pid, Stanza.message(message.type, to, message.body))
    end
    {:ok, opts}
  end

  def handle_event(_, opts), do: {:ok, opts}
end
