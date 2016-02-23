defmodule Hedwig.ConfigTest do
  use ExUnit.Case

  test "missing otp config" do
    assert_raise ArgumentError, fn ->
      Hedwig.Robot.Supervisor.config(NoSuchApp.Robot, :no_such_app, [])
    end
  end

  test "parse config (ok)" do
    opts = [otp_app: :alfred, adapter: Hedwig.Adapters.Console]
    result = Hedwig.Robot.Supervisor.parse_config(Alfred.Robot, opts)
    assert result == {:alfred, Hedwig.Adapters.Console, []}
  end

  test "parse config (missing adapter keyword)" do
    opts = [otp_app: :alfred]
    assert_raise ArgumentError, fn ->
      Hedwig.Robot.Supervisor.parse_config(Alfred.Robot, opts)
    end
  end

  test "parse config (missing adapter code)" do
    opts = [otp_app: :alfred, adapter: Hedwig.Adapters.NoSuchAdapter]
    assert_raise ArgumentError, fn ->
      Hedwig.Robot.Supervisor.parse_config(Alfred.Robot, opts)
    end
  end
end
