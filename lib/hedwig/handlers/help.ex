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
    |> Enum.filter(fn {mod, _opts} -> not is_nil(mod.usage) end)
    |> Enum.map_join "", fn {mod, _opts} ->
      replace_nickname(mod.usage, nickname)
    end
    reply(msg, Stanza.body(help))
  end

  defp replace_nickname(usage, nickname) do
    String.replace(usage, "hedwig", nickname)
  end
end
