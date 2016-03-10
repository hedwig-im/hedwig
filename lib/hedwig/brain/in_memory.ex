defmodule Hedwig.Brain.InMemory do

  @behaviour Hedwig.Brain

  def start_link do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
  end

  def memorize(key, info) do
    Agent.update(__MODULE__, &MapSet.put(&1, key, info))
  end

  def remember(key) do
    Agent.get(__MODULE__, &MapSet.get(&1, key))
  end

  def forget(key) do
    Agent.update(__MODULE__, &MapSet.pop(&1, key))
  end
end
