defmodule Hedwig.ConfigTest do
  use ExUnit.Case

  test "missing otp config" do
    assert_raise ArgumentError, fn ->
      Hedwig.Robot.Supervisor.config(NoSuchApp.Robot, :no_such_app, [])
    end
  end

  test "parse config (ok)" do
    opts = [otp_app: :alfred, adapter: Hedwig.Adapters.Console, name: "hedwig"]
    result = Hedwig.Robot.Supervisor.parse_config(Alfred.Robot, opts)
    assert result == {:alfred, Hedwig.Adapters.Console, []}
  end

  test "parse config (missing adapter keyword)" do
    opts = [otp_app: :alfred, name: "hedwig"]
    assert_raise ArgumentError, fn ->
      Hedwig.Robot.Supervisor.parse_config(Alfred.Robot, opts)
    end
  end

  test "parse config (missing adapter code)" do
    opts = [otp_app: :alfred, adapter: Hedwig.Adapters.NoSuchAdapter, name: "hedwig"]
    assert_raise ArgumentError, fn ->
      Hedwig.Robot.Supervisor.parse_config(Alfred.Robot, opts)
    end
  end

  test "parse config (missing name keyword)" do
    opts = [otp_app: :alfred, adapter: Hedwig.Adapters.Console]
    assert_raise ArgumentError, fn ->
      Hedwig.Robot.Supervisor.parse_config(Alfred.Robot, opts)
    end
  end

  test "parse config (with incorrect name)" do
    opts = [otp_app: :alfred, adapter: Hedwig.Adapters.Console, name: ""]
    assert_raise ArgumentError, fn ->
      Hedwig.Robot.Supervisor.parse_config(Alfred.Robot, opts)
    end
  end
end
