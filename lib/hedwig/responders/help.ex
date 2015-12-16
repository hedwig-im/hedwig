defmodule Hedwig.Responders.Help do
  use Hedwig.Responder

  @usage """
  hedwig help - Displays all of the help commands that hedwig knows about.
  """
  respond ~r/help$/, %{robot: robot} = msg do
    reply msg, display_usage(robot)
  end

  @usage """
  hedwig help <query> - Displays all help commands that match <query>.
  """
  respond ~r/help (?<query>.*)/, %{robot: robot} = msg do
    reply msg, search(robot, msg.matches["query"])
  end

  defp display_usage(robot) do
    robot
    |> all_usage
    |> Enum.reverse
    |> Enum.map_join("\n", &(&1))
  end

  defp search(robot, query) do
    robot
    |> all_usage
    |> Enum.reverse
    |> Enum.filter(&(String.match?(&1, ~r/(#{query})/i)))
    |> Enum.map_join("\n", &(&1))
  end

  defp all_usage(%{name: name, opts: opts}) do
    Enum.reduce opts[:responders], [], fn {mod, _opts}, acc ->
      mod.usage(name) ++ acc
    end
  end
end
