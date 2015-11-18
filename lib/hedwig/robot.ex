defmodule Hedwig.Robot do
  @moduledoc """
  """

  @type name :: binary
  @type store :: pid
  @type adapter :: module

  defstruct name: "", brain: nil, adapter: nil, handlers: []

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Hedwig.Robot

      {otp_app, adapter, config} = Hedwig.Robot.Supervisor.parse_config(__MODULE__, opts)
      @otp_app otp_app
      @adapter adapter
      @config  config
      @before_compile adapter

      require Logger
      @log_level config[:log_level] || :debug

      def config(opts \\ []) do
        Hedwig.Robot.Supervisor.config(__MODULE__, @otp_app, opts)
      end

      def start_link(opts \\ []) do
        Hedwig.Robot.Supervisor.start_link(__MODULE__, @otp_app, @adapter, opts)
      end

      def log(message) do
        Logger.unquote(@log_level)(fn ->
          IO.inspect message
        end, [])
      end

      def __adapter__ do
        @adapter
      end

      defoverridable [log: 1]
    end
  end
end
