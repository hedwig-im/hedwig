Code.ensure_compiled(Hedwig.Adapters.Test)

defmodule Hedwig.TestRobot do
  use Hedwig.Robot, otp_app: :hedwig, adapter: Hedwig.Adapters.Test

  def after_connect(state) do
    {:ok, state}
  end
end
