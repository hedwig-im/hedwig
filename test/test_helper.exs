config = [adapter: Hedwig.Adapters.Test, name: "hedwig", aka: "/"]
Application.put_env(:hedwig, Hedwig.TestRobot, config)
Application.put_env(:hedwig, Hedwig.EvalBot, config)

ExUnit.start()

defmodule EvalBot do
  use Hedwig.Robot,
    otp_app: :hedwig,
    adapter: Hedwig.Adapters.Test

  def init(fun) when is_function(fun, 0), do: fun.()
  def init(state), do: {:ok, state}
end
