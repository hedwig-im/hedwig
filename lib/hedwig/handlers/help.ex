defmodule Hedwig.Handlers.Help do
  @moduledoc """
  Displays usage for all installed handlers.
  """

  @usage """
  hedwig: help - Displays this help menu
  """
  use Hedwig.Handler

  def handle_event(%Message{delayed?: false} = msg, opts) do
    nickname = opts.client.nickname
    cond do
      hear ~r/^#{nickname}(:)? help$/i, msg ->
        process_help(msg, nickname)
      true -> :ok
    end
    {:ok, opts}
  end
  def handle_event(_msg, opts), do: {:ok, opts}

  defp process_help(msg, nickname) do
    help = Client.get(msg.client, :handlers)
    |> Enum.map_join "---\n", fn {mod, _opts} ->
      replace_nickname(mod.usage, nickname)
    end
    reply(msg, Stanza.body(help))
  end

  defp replace_nickname(nil, _nickname), do: ""
  defp replace_nickname(usage, nickname) do
    String.replace(usage, "hedwig", nickname)
  end
end
