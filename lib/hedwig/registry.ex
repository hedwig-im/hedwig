defmodule Hedwig.Registry do
  @moduledoc false

  @doc """
  Registers a `name` for the current process.
  """
  def register(name) do
    true = :gproc.reg({:n, :l, name})
  end

  @doc """
  Looks up the robot pid for `name`.

  Returns `pid` in case a robot exists, `:undefined` otherwise.
  """
  def whereis(name) do
    :gproc.whereis_name({:n, :l, name})
  end
end
