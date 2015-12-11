defmodule Hedwig.Robot do
  @moduledoc """
  Robots receive messages from a chat source (XMPP, IRC, Console, etc), and
  dispatch them to matching responders.
  """

  defstruct adapter: nil,
            aka: nil,
            brain: nil,
            name: "",
            opts: [],
            responders: []

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use GenServer
      require Logger

      {otp_app, adapter, config} = Hedwig.Robot.Supervisor.parse_config(__MODULE__, opts)
      @adapter adapter
      @before_compile adapter
      @config  config
      @log_level config[:log_level] || :debug
      @otp_app otp_app

      def start_link(opts \\ []) do
        Hedwig.Robot.start_link(__MODULE__, opts)
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
        {:ok, brain} = Hedwig.Brain.start_link

        {aka, opts} = Keyword.pop(opts, :aka)
        {name, opts} = Keyword.pop(opts, :name)

        GenServer.cast(self, :install_responders)

        state = %Hedwig.Robot{adapter: adapter, aka: aka, brain: brain,
                              name: name, opts: opts}
        {:ok, state}
      end

      def handle_cast(%Hedwig.Message{} = msg, %{responders: responders} = state) do
        Hedwig.Responder.run(%{msg | robot: state}, responders)
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

      defoverridable terminate: 2, code_change: 3, handle_info: 2
    end
  end

  def start_link(robot, opts) do
    GenServer.start_link(robot, {robot, opts})
  end

  def handle_message(robot, %Hedwig.Message{} = msg) do
    GenServer.cast(robot, msg)
  end
end
