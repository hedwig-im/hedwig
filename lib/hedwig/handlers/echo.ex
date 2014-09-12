defmodule Hedwig.Handlers.Echo do
  @moduledoc """
  A completely useless echo script.

  This script simply echoes the same message back.
  """
  use Hedwig.Handler

  def handle_event(%{delayed?: true}, opts), do: {:ok, opts}

  def handle_event(%Message{} = msg, opts) do
    reply(msg, msg.body)
    {:ok, opts}
  end

  def handle_event(_, opts), do: {:ok, opts}
end
