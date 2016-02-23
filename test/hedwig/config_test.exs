defmodule Hedwig.ConfigTest do
  use ExUnit.Case

  test "missing otp config" do
    assert_raise ArgumentError, fn ->
      Hedwig.Robot.Supervisor.config(NoSuchApp.Robot, :no_such_app, [])
    end
  end
end
