defmodule HedwigTest do
  use Hedwig.RobotCase

  @tag start_robot: true
  test "list started robots", %{robot: pid} do
    assert [{_id, ^pid, _type, [Hedwig.Robot]}] = Hedwig.which_robots()
  end

  @tag start_robot: true, name: "codsworth"
  test "find a robot by name", %{robot: pid} do
    assert :undefined == :global.whereis_name("hedwig")
    assert ^pid = :global.whereis_name("codsworth")
  end

  @tag start_robot: true
  test "handle_in/2", %{robot: pid} do
    Hedwig.Robot.handle_in(pid, {:ping, self()})
    assert_receive :pong
  end

  @tag start_robot: true
  test "stop_robot/1", %{robot: pid} do
    Hedwig.stop_robot(pid)
    refute Process.alive?(pid)
  end
end
