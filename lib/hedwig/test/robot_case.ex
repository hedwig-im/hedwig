defmodule Hedwig.RobotCase do
  use ExUnit.CaseTemplate

  @robot Hedwig.TestRobot
  @default_responders [{Hedwig.Responders.Help, []}, 
                       {TestResponder, []},
                       {TestIdentityResponder, []}]

  using do
    quote do
      import unquote(__MODULE__)
      @robot Hedwig.TestRobot
    end
  end

  setup tags do
    if tags[:start_robot] do
      robot = Map.get(tags, :robot, @robot)
      name = Map.get(tags, :name, "hedwig")
      responders = Map.get(tags, :responders, @default_responders)

      config = [name: name, aka: "/", responders: responders]

      Application.put_env(:hedwig, robot, config)
      {:ok, pid} = Hedwig.start_robot(robot, config)
      adapter = update_robot_adapter(pid)

      on_exit fn -> Hedwig.stop_robot(pid) end

      msg = %Hedwig.Message{robot: pid, text: "", user: "testuser"}

      {:ok, %{robot: pid, adapter: adapter, msg: msg}}
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
