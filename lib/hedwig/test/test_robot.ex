Code.ensure_compiled(Hedwig.Adapters.Test)

defmodule Hedwig.TestRobot do
  use Hedwig.Robot, otp_app: :hedwig, adapter: Hedwig.Adapters.Test

  def handle_connect(%{name: name} = state) do
    Hedwig.Registry.register(name)
    {:ok, state}
  end

  def handle_in({:ping, from}, robot) do
    Kernel.send(from, :pong)
    {:ok, robot}
  end

  def handle_in(_msg, robot) do
    {:ok, robot}
  end
end
