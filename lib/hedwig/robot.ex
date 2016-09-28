defmodule Hedwig.Robot do
  @moduledoc """
  Defines a robot.

  Robots receive messages from a chat source (XMPP, Slack, Console, etc), and
  dispatch them to matching responders. See the documentation for
  `Hedwig.Responder` for details on responders.

  When used, the robot expects the `:otp_app` as option. The `:otp_app` should
  point to an OTP application that has the robot configuration. For example,
  the robot:

      defmodule MyApp.Robot do
        use Hedwig.Robot, otp_app: :my_app
      end

  Could be configured with:

      config :my_app, MyApp.Robot,
        adapter: Hedwig.Adapters.Console,
        name: "alfred"

  Most of the configuration that goes into the `config` is specific to the
  adapter.  Be sure to check the documentation for the adapter in use for all
  of the available options.

  ## Robot configuration

  * `adapter` - the adapter module name.
  * `name` - the name the robot will respond to.
  * `aka` - an alias the robot will respond to.
  * `log_level` - the level to use when logging output.
  * `responders` - a list of responders specified in the following format:
    `{module, kwlist}`.
  """

  defstruct adapter: nil,
            aka: nil,
            name: "",
            opts: [],
            pid: nil,
            responders: []

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      use GenServer
      require Logger

      {otp_app, adapter, robot_config} =
        Hedwig.Robot.Supervisor.parse_config(__MODULE__, opts)

      @adapter adapter
      @before_compile adapter
      @config  robot_config
      @log_level robot_config[:log_level] || :debug
      @otp_app otp_app

      def start_link(opts \\ []) do
        Hedwig.start_robot(__MODULE__, opts)
      end

      def stop(robot) do
        Hedwig.stop_robot(robot)
      end

      def config(opts \\ []) do
        Hedwig.Robot.Supervisor.config(__MODULE__, @otp_app, opts)
      end

      def log(msg) do
        Logger.unquote(@log_level)(fn ->
          "#{inspect msg}"
        end, [])
      end

      def __adapter__, do: @adapter

      def init({robot, opts}) do
        opts = Keyword.merge(robot.config, opts)
        {:ok, adapter} = @adapter.start_link(robot, opts)

        {aka, opts}   = Keyword.pop(opts, :aka)
        {name, opts}  = Keyword.pop(opts, :name)
        responders    = Keyword.get(opts, :responders, [])

        unless responders == [] do
          GenServer.cast(self, :install_responders)
        end

        {:ok, %Hedwig.Robot{
          adapter: adapter,
          aka: aka,
          name: name,
          opts: opts,
          pid: self()}}
      end

      def handle_connect(state) do
        Logger.warn """
        #{inspect __MODULE__}.handle_connect/1 default handler invoked.
        """
        {:ok, state}
      end

      def handle_disconnect(_reason, state) do
        Logger.warn """
        #{inspect __MODULE__}.handle_disconnect/2 default handler invoked.
        """
        {:reconnect, state}
      end

      def handle_in(msg, state) do
        Logger.warn """
        #{inspect __MODULE__}.handle_in/2 default handler invoked.
        """
        {:ok, state}
      end

      def handle_call(:handle_connect, _from, state) do
        case __MODULE__.handle_connect(state) do
          {:ok, state} ->
            {:reply, :ok, state}
          {:stop, reason, state} ->
            {:stop, reason, state}
        end
      end

      def handle_call({:handle_disconnect, reason}, _from, state) do
        case __MODULE__.handle_disconnect(reason, state) do
          {:reconnect, state} ->
            {:reply, :reconnect, state}
          {:disconnect, reason, state} ->
            Process.unlink(state.adapter)
            {:stop, reason, {:disconnect, reason}, state}
        end
      end

      def handle_cast({:send, msg}, %{adapter: adapter} = state) do
        @adapter.send(adapter, msg)
        {:noreply, state}
      end

      def handle_cast({:reply, msg}, %{adapter: adapter} = state) do
        @adapter.reply(adapter, msg)
        {:noreply, state}
      end

      def handle_cast({:emote, msg}, %{adapter: adapter} = state) do
        @adapter.emote(adapter, msg)
        {:noreply, state}
      end

      def handle_cast({:register, name}, state) do
        Hedwig.Registry.register(name)
        {:noreply, state}
      end

      def handle_cast(%Hedwig.Message{} = msg, %{responders: responders} = state) do
        Hedwig.Responder.run(%{msg | robot: %{state | responders: []}}, responders)
        {:noreply, state}
      end

      def handle_cast({:handle_in, msg}, state) do
        {:ok, state} = __MODULE__.handle_in(msg, state)
        {:noreply, state}
      end

      def handle_cast(:install_responders, %{opts: opts} = state) do
        responders =
          Enum.reduce opts[:responders], [], fn {mod, opts}, acc ->
            mod.install(state, opts) ++ acc
          end
        {:noreply, %{state | responders: responders}}
      end

      def handle_info(msg, state) do
        {:noreply, state}
      end

      def terminate(_reason, _state) do
        :ok
      end

      def code_change(_old, state, _extra) do
        {:ok, state}
      end

      defoverridable [
        {:handle_connect, 1},
        {:handle_disconnect, 2},
        {:handle_in, 2},
        {:terminate, 2},
        {:code_change, 3},
        {:handle_info, 2}
      ]
    end
  end

  @doc false
  def start_link(robot, opts) do
    GenServer.start_link(robot, {robot, opts})
  end

  @doc """
  Send a message via the robot.
  """
  def send(pid, msg) do
    GenServer.cast(pid, {:send, msg})
  end

  @doc """
  Send a reply message via the robot.
  """
  def reply(pid, msg) do
    GenServer.cast(pid, {:reply, msg})
  end

  @doc """
  Send an emote message via the robot.
  """
  def emote(pid, msg) do
    GenServer.cast(pid, {:emote, msg})
  end

  @doc """
  Handles invoking installed responders with a `Hedwig.Message`.

  This function should be called by an adapter when a message arrives. A message
  will be sent to each installed responder.
  """
  @spec handle_message(pid, Hedwig.Message.t) :: :ok
  def handle_message(robot, %Hedwig.Message{} = msg) do
    GenServer.cast(robot, msg)
  end

  @doc """
  Invokes a user defined `handle_in/2` function, if defined.

  This function should be called by an adapter when a message arrives but
  should be handled by the user.
  """
  @spec handle_in(pid, any) :: :ok
  def handle_in(robot, msg) do
    GenServer.cast(robot, {:handle_in, msg})
  end

  @doc """
  Invokes a user defined `handle_connect/1` function, if defined.

  If the user has defined an `handle_connect/1` in the robot module, it will be
  called with the robot's state. It is expected that the function return
  `{:ok, state}` or `{:stop, reason, state}`.
  """
  @spec handle_connect(pid, integer) :: :ok
  def handle_connect(robot, timeout \\ 5000) do
    GenServer.call(robot, :handle_connect, timeout)
  end

  @doc """
  Invokes a user defined `handle_disconnect/1` function, if defined.

  If the user has defined an `handle_disconnect/1` in the robot module, it will be
  called with the robot's state. It is expected that the function return
  `{:reconnect, state}` or `{:disconnect, reason, state}`.
  """
  @spec handle_disconnect(pid, any, integer) :: :ok
  def handle_disconnect(robot, reason, timeout \\ 5000) do
    GenServer.call(robot, {:handle_disconnect, reason}, timeout)
  end

  @doc """
  Allows a robot to be registered by name.
  """
  @spec register(pid, any) :: :ok
  def register(robot, name) do
    GenServer.cast(robot, {:register, name})
  end
end
