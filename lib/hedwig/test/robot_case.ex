defmodule Hedwig.RobotCase do
  use ExUnit.CaseTemplate

  @adapter Hedwig.Adapters.Test
  @robot Hedwig.TestRobot
  @default_responders [{Hedwig.Responders.Help, []}, {TestResponder, []}]

  using do
    quote do
      use ExUnit.Case, async: false
      import unquote(__MODULE__)
      @robot Hedwig.TestRobot
    end
  end

  setup tags do
    if tags[:start_robot] do
      adapter = Map.get(tags, :adapter, @adapter)
      robot = Map.get(tags, :robot, @robot)
      name = Map.get(tags, :name, "hedwig")
      responders = Map.get(tags, :responders, @default_responders)

      config = [adapter: adapter, name: name, aka: "/", responders: responders]

      {:ok, pid} = robot.start_link(config)

      adapter = update_robot_adapter(pid)

      #on_exit fn -> Hedwig.Robot.stop(pid) end

      msg = %Hedwig.Message{robot: pid, text: "", user: "testuser"}

      {:ok, robot: pid, adapter: adapter, msg: msg}
    else
      {:ok, tags}
    end
  end

  def update_robot_adapter(robot) do
    test_process = self()
    adapter = :sys.get_state(robot).adapter
    :sys.replace_state(adapter, fn state -> %{state | conn: test_process} end)

    adapter
  end
end
