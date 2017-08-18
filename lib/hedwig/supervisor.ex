defmodule Hedwig.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: Hedwig.Supervisor)
  end

  def init(:ok) do
    supervise([], strategy: :one_for_one)
  end
end
