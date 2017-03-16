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

  def collection_fill_opts(opts), do: [{A, opts}, {B, opts}]

  @tag start_robot: true, responders: [{Hedwig.RobotTest, :collection_fill_opts, [foo: "bar"]}]
  test "collect_responders/1 expands responder list with common options", %{robot: robot} do
    assert [{A, [foo: "bar"]}, {B, [foo: "bar"]}] = Hedwig.Robot.responders(robot)
  end

  def collection_empty_opts(_opts), do: [{A, []}, {B, []}]

  @tag start_robot: true, responders: [{Hedwig.RobotTest, :collection_empty_opts, [foo: "bar"]}]
  test "collect_responders/1 expands responder list", %{robot: robot} do
    assert [{A, []}, {B, []}] = Hedwig.Robot.responders(robot)
  end

  @tag start_robot: true, responders: [{TestResponder, []}, {Hedwig.RobotTest, :collection_empty_opts, []}]
  test "collect_responders/1 includes normal responder definition at start", %{robot: robot} do
    assert [{TestResponder, []}, {A, []}, {B, []}] = Hedwig.Robot.responders(robot)
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
