defmodule Hedwig.Registry do
  @moduledoc false

  @doc """
  Registers a `name` for the current process.
  """
  def register_name(name) do
    true = :gproc.reg({:n, :l, name})
  end

  @doc """
  Registers a `property` for the current process.
  """
  def register_property(property) do
    true = :gproc.reg({:p, :l, property})
  end

  @doc """
  Looks up the robot pid for `name`.

  Returns `pid` in case a robot exists, `:undefined` otherwise.
  """
  def whereis_name(name) do
    :gproc.whereis_name({:n, :l, name})
  end

  @doc """
  Looks up the robot pid for the given `property`.

  Returns `pid` in case a robot exists, `:undefined` otherwise.
  """
  def whereis_property(property) do
    :gproc.whereis_name({:p, :l, property})
  end
end
