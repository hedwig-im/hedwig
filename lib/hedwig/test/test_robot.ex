Code.ensure_compiled(Hedwig.Adapters.Test)

defmodule Hedwig.TestRobot do
  use Hedwig.Robot, otp_app: :hedwig, adapter: Hedwig.Adapters.Test, name: "hedwig"

  def after_connect(%{name: name} = robot) do
    Hedwig.Robot.register(self, name)
    {:ok, robot}
  end

  def handle_in({:ping, from}, robot) do
    Kernel.send(from, :pong)
    {:ok, robot}
  end

  def handle_in(msg, robot) do
    {:ok, robot}
  end
end
