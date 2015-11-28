defmodule Hedwig.Robot do
  @moduledoc """
  Robots receive messages from a chat source (XMPP, IRC, etc), and
  dispatch them to matching message handlers.
  """

  @type name :: binary
  @type store :: pid
  @type adapter :: module

  defstruct adapter: nil,
            brain: nil,
            handlers: [],
            name: "",
            opts: []

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Hedwig.Robot
      use GenServer

      {otp_app, adapter, config} = Hedwig.Robot.Supervisor.parse_config(__MODULE__, opts)
      @otp_app otp_app
      @adapter adapter
      @config  config
      @before_compile adapter

      require Logger
      @log_level config[:log_level] || :debug

      def start_link(opts \\ []) do
        Hedwig.Robot.start_link(__MODULE__, opts)
      end

      def stop(pid) do
        Hedwig.stop_robot(pid)
      end

      def send(pid, msg) do
        GenServer.call(pid, {:send, msg})
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
        {:ok, adapter} = robot.__adapter__.start_link(robot, opts)
        {:ok, brain} = Hedwig.Brain.start_link
        {:ok, %Hedwig.Robot{adapter: adapter, brain: brain, opts: opts}}
      end

      def handle_call({:send, msg}, _from, %{adapter: pid} = state) do
        @adapter.send(pid, msg)
        {:reply, :ok, state}
      end

      def handle_info(msg, state) do
        log(msg)
        {:noreply, state}
      end

      defoverridable [log: 1, handle_info: 2]
    end
  end

  def start_link(robot, opts) do
    GenServer.start_link(robot, {robot, opts})
  end
end
