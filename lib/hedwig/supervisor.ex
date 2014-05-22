defmodule Hedwig.Supervisor do
  use Supervisor.Behaviour

  def start_link(opts) do
    :supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    children = [ worker(Hedwig.Client, []) ]
    supervise children, strategy: :one_for_one
  end
end
