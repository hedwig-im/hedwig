defmodule Hedwig.Responders.Help do
  @moduledoc """
  The Help Responder.

  This responder is responsible for displaying the usage for all installed
  responders.

  ## Installation

  Add this responder to your bot's list of responders:

      responders: [
        {Hedwig.Responders.Help, []}
      ]

  ## Usage

  You can invoke this responder by mentioning your bot's name followed by 'help'
  (hedwig help). Your bot will reply back with a list of usage text for each
  responder installed.

  ## Searching help

  If you include a search term, your bot will only respond with help that matches
  (hedwig help <query>).
  """

  use Hedwig.Responder

  @usage """
  hedwig help - Displays all of the help commands that hedwig knows about.
  """
  respond ~r/help$/, msg, state do
    send msg, display_usage(state)
  end

  @usage """
  hedwig help <query> - Displays all help commands that match <query>.
  """
  respond ~r/help (?<query>.*)/, msg, state do
    send msg, search(state, msg.matches["query"])
  end

  defp display_usage(state) do
    state
    |> all_usage()
    |> Enum.reverse()
    |> Enum.map_join("\n", &(&1))
  end

  defp search(state, query) do
    state
    |> all_usage()
    |> Enum.reverse()
    |> Enum.filter(&(String.match?(&1, ~r/(#{query})/i)))
    |> Enum.map_join("\n", &(&1))
  end

  defp all_usage(%{name: name, robot: robot}) do
    responders = Hedwig.Robot.responders(robot)
    Enum.reduce responders, [], fn {mod, _opts}, acc ->
      mod.usage(name) ++ acc
    end
  end
end
