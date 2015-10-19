defmodule Hedwig.Handlers.Panzy do
  @moduledoc """
  Says 'Panzy!' whenever someone is being a whiner.
  """

  @usage """
  <text> (tired|too hard|to hard|upset|bored) - Replies with 'Panzy!'
  """

  use Hedwig.Handler

  def handle_event(%Message{} = msg, opts) do
    cond do
      hear ~r/tired|too? hard|upset|bored/i, msg ->
        panzy!(msg)
      true ->
        :ok
    end
    {:ok, opts}
  end

  def handle_event(_, opts), do: {:ok, opts}

  defp panzy!(msg) do
    body = "Panzy!"
    html = "<p><strong>#{body}</strong></p>"
    reply(msg, [Stanza.body(body), Stanza.xhtml_im(html)])
  end
end
