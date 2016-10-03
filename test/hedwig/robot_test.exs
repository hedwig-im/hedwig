defmodule Hedwig.RobotTest do
  use ExUnit.Case
  use Hedwig.RobotCase

  @tag start_robot: true, name: "alfred"
  test "name/1 returns the name of the robot", %{robot: robot} do
    assert "alfred" = Hedwig.Robot.name(robot)
  end

  @tag start_robot: true, responders: [{TestResponder, []}]
  test "responders/1 returns the list of configured responders", %{robot: robot} do
    assert [{TestResponder, []}] = Hedwig.Robot.responders(robot)
  end

  @tag start_robot: true
  test "handle_connect/1", %{robot: robot} do
    assert ^robot = :global.whereis_name("hedwig")
  end

  @tag start_robot: true
  test "handle_disconnect/1", %{robot: robot} do
    import Hedwig.Robot
    assert :reconnect == handle_disconnect(robot, :reconnect)
    assert {:reconnect, 5000} == handle_disconnect(robot, {:reconnect, 5000})
    assert {:disconnect, :normal} == handle_disconnect(robot, :error)
  end
end
