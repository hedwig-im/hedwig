defmodule Hedwig.Responders.Help do
  use Hedwig.Responder

  @usage """
  hedwig: help - Displays the usage for all installed responders.
  """
  respond ~r/help/, msg do
    usage =
      msg.robot.opts[:responders]
      |> Enum.map_join("\n", fn {mod, _opts} ->
        mod.usage(msg.robot.name)
      end)
    %{msg | text: usage}
  end
end
