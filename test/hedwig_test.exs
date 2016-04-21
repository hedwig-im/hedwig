defmodule HedwigTest do
  use Hedwig.RobotCase

  @tag start_robot: true
  test "list started robots", %{robot: pid} do
    assert [{_id, ^pid, _type, [Hedwig.Robot]}] = Hedwig.which_robots()
  end

  @tag start_robot: true, name: "codsworth"
  test "find a robot by name", %{robot: pid} do
    assert Hedwig.whereis("hedwig") == :undefined
    assert Hedwig.whereis("codsworth") == pid
  end
  @tag start_robot: true
  test "handle_in/2", %{robot: pid} do
    Hedwig.Robot.handle_in(pid, {:ping, self()})
    assert_receive :pong
  end
end
