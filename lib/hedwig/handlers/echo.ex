defmodule Hedwig.Handlers.Echo do
  @moduledoc """
  A completely useless echo script.

  This script simply echoes the same message back.
  """
  use Hedwig.Handler

  def handle_event(%Message{from: from, delayed?: false} = msg, opts) do
    if not from_self?(from, opts.client) and not from_muc_room?(from) do
      to = JID.bare(from)
      reply(msg, msg.body)
    end
    {:ok, opts}
  end

  def handle_event(_, opts), do: {:ok, opts}
end
