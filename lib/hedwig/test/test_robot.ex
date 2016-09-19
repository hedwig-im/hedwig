Code.ensure_compiled(Hedwig.Adapters.Test)

defmodule Hedwig.TestRobot do
  use Hedwig.Robot, otp_app: :hedwig, adapter: Hedwig.Adapters.Test

  def after_connect(%{name: name} = robot) do
    Hedwig.Robot.register(self, name)
    {:ok, robot}
  end

  def handle_in({:ping, from}, robot) do
    Kernel.send(from, :pong)
    {:ok, robot}
  end

  def handle_in(_msg, robot) do
    {:ok, robot}
  end
end
