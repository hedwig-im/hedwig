defmodule Hedwig.Client.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    opts = [strategy: :simple_one_for_one, restart: :transient]
    supervise([worker(Hedwig.Client, [])], opts)
  end
end

