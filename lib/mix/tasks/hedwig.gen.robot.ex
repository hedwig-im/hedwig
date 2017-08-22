defmodule Mix.Tasks.Hedwig.Gen.Robot do
  use Mix.Task

  import Mix.Generator

  @shortdoc "Generate a new robot"

  @moduledoc """
  Generates a new robot.

  The robot will be placed in the `lib` directory.

  ## Examples

      mix hedwig.gen.robot
      mix hedwig.gen.robot --name alfred --robot Custom.Module

  ## Command line options

    * `--name` - the name your robot will respond to
    * `--aka` - an alias your robot will respond to
    * `--robot` - the robot to generate (defaults to `YourApp.Robot`)

  """
  @switches [aka: :string, name: :string, robot: :string]

  @doc false
  def run(argv) do

    if Mix.Project.umbrella? do
      Mix.raise "cannot run task hedwig.gen.robot from umbrella application"
    end

    config  = Mix.Project.config

    {opts, _argv, _} = OptionParser.parse(argv, switches: @switches)

    app = config[:app]
    deps = config[:deps]

    Mix.shell.info [:clear, :home, """
    Welcome to the Hedwig Robot Generator!

    Let's get started.
    """]

    aka     = opts[:aka]   || "/"
    name    = opts[:name]  || prompt_for_name()
    robot   = opts[:robot] || default_robot(app)
    adapter = get_adapter_module(deps)

    underscored = Macro.underscore(robot)
    file = Path.join("lib", underscored) <> ".ex"

    robot = Module.concat([robot])

    opts = [adapter: adapter, aka: aka, app: app, name: name, robot: robot]

    create_directory Path.dirname(file)
    create_file file, robot_template(opts)

    case File.read "config/config.exs" do
      {:ok, contents} ->
        Mix.shell.info [:green, "* updating ", :reset, "config/config.exs"]
        File.write! "config/config.exs",
                    String.replace(contents, "use Mix.Config", config_template(opts))
      {:error, _} ->
        create_file "config/config.exs", config_template(opts)
    end

    Mix.shell.info """

    Don't forget to add your new robot to your supervision tree
    (typically in lib/#{app}.ex):

        worker(#{inspect robot}, [])
    """
  end

  defp default_robot(app) do
    case Application.get_env(app, :app_namespace, app) do
      ^app -> app |> to_string |> Macro.camelize
      mod  -> mod |> inspect
    end |> Module.concat(Robot)
  end

  defp available_adapters(deps) do
    deps
    |> all_modules
    |> Kernel.++(hedwig_modules())
    |> Enum.uniq
    |> Enum.filter(&implements_adapter?/1)
    |> Enum.with_index
    |> Enum.reduce(%{}, fn {adapter, index}, acc ->
      Map.put(acc, index + 1, adapter)
    end)
  end

  defp all_modules(deps) do
    Enum.reduce(deps, [], &load_and_get_modules/2)
  end

  defp load_and_get_modules({app, _}, acc) do
    load_and_get_modules(app, acc)
  end
  defp load_and_get_modules({app, _, _}, acc) do
    load_and_get_modules(app, acc)
  end
  defp load_and_get_modules(app, acc) do
    Application.load(app)
    case :application.get_key(app, :modules) do
      {:ok, modules} ->
        modules ++ acc
      _ ->
        acc
    end
  end

  defp hedwig_modules do
    Application.load(:hedwig)
    {:ok, modules} = :application.get_key(:hedwig, :modules)
    modules
  end

  defp implements_adapter?(module) do
    case get_in(module.module_info(), [:attributes, :hedwig_adapter]) do
      nil  -> false
      [true] -> true
    end
  end

  defp get_adapter_module(deps) do
    adapters = available_adapters(deps)
    {selection, _} = adapters |> prompt_for_adapter |> Integer.parse
    adapters[selection]
  end

  defp prompt_for_name do
    Mix.shell.prompt("What would you like to name your bot?:")
    |> String.trim
  end

  defp prompt_for_adapter(adapters) do
    adapters = Enum.map(adapters, &format_adapter/1)
    Mix.shell.info ["Available adapters\n\n", adapters]
    Mix.shell.prompt("Please select an adapter:")
  end

  defp format_adapter({index, mod}) do
    [inspect(index), ". ", :bright, :blue,
     inspect(mod), :normal, :default_color, "\n"]
  end

  embed_template :robot, """
  defmodule <%= inspect @robot %> do
    use Hedwig.Robot

    def start_link do
      args = Application.get_env(<%= inspect @app %>, __MODULE__)
      Hedwig.Robot.start_link(__MODULE__, args, name: __MODULE__)
    end

    def handle_disconnect(_reason, state) do
      {:reconnect, 5000, state}
    end

    def handle_in(%Hedwig.Message{} = msg, state) do
      {:dispatch, msg, state}
    end

    def handle_in(_msg, state) do
      {:noreply, state}
    end
  end
  """

  embed_template :config, """
  use Mix.Config

  config <%= inspect @app %>, <%= inspect @robot %>,
    adapter: <%= inspect @adapter %>,
    name: <%= inspect @name %>,
    aka: <%= inspect @aka %>,
    responders: [
      {Hedwig.Responders.Help, []},
      {Hedwig.Responders.Ping, []}
    ]
  """
end
