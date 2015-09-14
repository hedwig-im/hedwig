defmodule Hedwig.Registry do
  @moduledoc false

  @doc """
  Registers a `jid` for the current process.
  """
  def register(jid) do
    true = :gproc.reg({:n, :l, jid})
  end

  @doc """
  Looks up the client pid for `jid`.

  Returns `pid` in case a client exists, `:undefined` otherwise.
  """
  def whereis(jid) do
    :gproc.whereis_name({:n, :l, jid})
  end
end
