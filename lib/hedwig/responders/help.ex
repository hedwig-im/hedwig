defmodule Hedwig.Responders.Help do
  use Hedwig.Responder

  respond ~r/help/, %{robot: robot} = msg do
   reply msg, all_usage(robot)
  end

  defp all_usage(%{name: name, opts: opts}) do
    Enum.map_join(opts[:responders], "\r", fn {mod, _opts} ->
      mod.usage(name)
    end)
  end
end
