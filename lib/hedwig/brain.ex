defmodule Hedwig.Brain do
  @moduledoc """
  Robot storage.
  """

  def start_link do
    Agent.start_link(fn -> %{users: [], private: %{}} end)
  end

  def get(brain) do
    Agent.get(brain, &(&1))
  end

  def get(brain, key) do
    state = get(brain)
    state.private[key]
  end

  def put(brain, key, value) do
    Agent.update(brain, fn %{private: private} = state ->
      %{state | private: Map.put(private, key, value)}
    end)
  end
end
