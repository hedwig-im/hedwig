defmodule Hedwig.Robot do
  @moduledoc """
  Robots receive messages from a chat source (XMPP, IRC, etc), and
  dispatch them to matching responders.
  """

  @type name :: binary
  @type store :: pid
  @type adapter :: module

  defstruct adapter: nil,
            aka: nil,
            brain: nil,
            name: "",
            opts: [],
            responders: []

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour GenServer

      {otp_app, adapter, config} = Hedwig.Robot.Supervisor.parse_config(__MODULE__, opts)
      @otp_app otp_app
      @adapter adapter
      @config  config
      @name config[:name]
      @aka config[:aka]

      @before_compile adapter

      require Logger
      @log_level config[:log_level] || :debug

      def start_link(opts \\ []) do
        Hedwig.Robot.start_link(__MODULE__, opts)
      end

      def stop(robot) do
        Hedwig.stop_robot(robot)
      end

      def send(robot, msg) do
        GenServer.call(robot, {:send, msg})
      end

      def config(opts \\ []) do
        Hedwig.Robot.Supervisor.config(__MODULE__, @otp_app, opts)
      end

      def log(message) do
        Logger.unquote(@log_level)(fn ->
          "#{inspect message}"
        end, [])
      end

      def __adapter__ do
        @adapter
      end

      def init({robot, opts}) do
        opts = Keyword.merge(robot.config, opts)
        {:ok, adapter} = @adapter.start_link(robot, opts)
        {:ok, brain} = Hedwig.Brain.start_link

        {aka, opts} = Keyword.pop(opts, :aka)
        {name, opts} = Keyword.pop(opts, :name)

        state = %Hedwig.Robot{
          adapter: adapter,
          aka: aka,
          brain: brain,
          name: name,
          opts: opts
        }

        Kernel.send(self, :install_responders)

        {:ok, state}
      end

      def handle_call({:send, msg}, _from, %{adapter: pid} = state) do
        @adapter.send(pid, msg)
        {:reply, :ok, state}
      end

      def handle_call({:run_responders, msg}, {from, _}, %{responders: responders} = state) do
        reply = %{msg | robot: state} |> Hedwig.Responder.run(responders)
        Kernel.send(from, {:reply, reply})
        {:reply, :ok, state}
      end

      def handle_info(:install_responders, %{opts: opts} = state) do
        responders =
          Enum.reduce opts[:responders], [], fn {mod, opts}, acc ->
            mod.install(state, opts) ++ acc
          end
        {:noreply, %{state | responders: responders}}
      end

      def terminate(_reason, _state) do
        :ok
      end

      def code_change(_old, state, _extra) do
        {:ok, state}
      end

      defoverridable terminate: 2, code_change: 3
    end
  end

  def start_link(robot, opts) do
    GenServer.start_link(robot, {robot, opts})
  end

  def handle_message(robot, msg) do
    GenServer.call(robot, {:run_responders, msg})
  end
end
