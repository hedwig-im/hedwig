defmodule Hedwig.Supervisor do
  @moduledoc false

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: Hedwig.Supervisor)
  end

  def init(:ok) do
    import Supervisor.Spec

    children = [
      supervisor(Hedwig.Client.Supervisor, [[name: Hedwig.Client.Supervisor]]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
