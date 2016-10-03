defmodule Hedwig.Responders.PingTest do
  use Hedwig.RobotCase

  @tag start_robot: true, name: "alfred", responders: [{Hedwig.Responders.Ping, []}]
  test "ping responds with pong", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "alfred ping"}}
    assert_receive {:message, %{text: "testuser: pong"}}
  end
end
