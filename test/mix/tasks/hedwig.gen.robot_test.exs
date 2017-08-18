defmodule Mix.Tasks.Hedwig.Gen.RobotTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  import Hedwig.FileHelpers
  import Mix.Tasks.Hedwig.Gen.Robot, only: [run: 1]

  test "generates a new robot" do
    in_tmp fn _ ->
      capture_io("1", fn -> run ["--name", "alfred"] end)

      assert_file "lib/hedwig/robot.ex", """
      defmodule Hedwig.Robot do
        use Hedwig.Robot
      """

      #assert_file "lib/hedwig/robot.ex", """
      #def handle_connect(%{name: name} = state) do
      #"""

      assert_file "lib/hedwig/robot.ex", """
      def handle_disconnect(_reason, state) do
      """

      assert_file "config/config.exs", """
      use Mix.Config

      config :hedwig, Hedwig.Robot,
        adapter: Hedwig.Adapters.Console,
        name: "alfred",
        aka: "/",
      """
    end
  end

  test "generates a new robot with existing config file" do
    in_tmp fn _ ->
      File.mkdir_p! "config"
      File.write! "config/config.exs", """
      # Hello
      use Mix.Config
      # World
      """

      capture_io("1", fn -> run ["--name", "alfred", "--robot", "Robot"] end)

      assert_file "config/config.exs", """
      # Hello
      use Mix.Config

      config :hedwig, Robot,
        adapter: Hedwig.Adapters.Console,
        name: "alfred",
        aka: "/",
        responders: [
          {Hedwig.Responders.Help, []},
          {Hedwig.Responders.Ping, []}
        ]

      # World
      """
    end
  end


  test "generates a new namespaced robot" do
    in_tmp fn _ ->
      capture_io("1", fn -> run ["--name", "alfred", "--robot", "MyApp.Robot"] end)
      assert_file "lib/my_app/robot.ex", "defmodule MyApp.Robot do"
    end
  end
end
