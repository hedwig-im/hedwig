defmodule Hedwig.RobotTest do
  use Hedwig.RobotCase


  test "__using__" do
    defmodule Robot do
      use Hedwig.Robot,
        otp_app: :hedwig,
        adapter: Hedwig.Adapters.Test
    end

    assert Robot.init(:my_state) == {:ok, :my_state}
    assert Robot.handle_connect(nil) == {:ok, nil}
    assert Robot.handle_disconnect(:my_reason, nil) ==
      {:reconnect, nil}
    assert catch_exit(Robot.handle_call(:my_call, {self(), make_ref()}, nil)) ==
      {:bad_call, :my_call}
    assert catch_exit(Robot.handle_cast(:my_cast, nil)) ==
      {:bad_cast, :my_cast}
    assert Robot.handle_info(:my_msg, nil) == {:noreply, nil}
    assert Robot.terminate(:my_reason, nil)
    assert Robot.code_change(:vsn, :my_state, :extra) == {:ok, :my_state}

  after
    :code.purge(Robot)
    :code.delete(Robot)
  end
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
