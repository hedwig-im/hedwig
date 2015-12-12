defmodule Hedwig.Adapter do
  @moduledoc """
  """

  use Behaviour

  defstruct conn: nil,
            opts: nil,
            robot: nil

  @doc false
  defmacro __using__(adapter \\ :undefined) do
    quote do
      @behaviour Hedwig.Adapter
      @conn __MODULE__.Connection
      @adapter unquote(adapter)

      @doc false
      defmacro __before_compile__(_env) do
        :ok
      end

      @doc false
      def start_link(robot, opts) do
        Hedwig.Adapter.start_link({__MODULE__, @conn, @adapter}, opts)
      end

      @doc false
      def stop(_robot, pid, timeout) do
        ref = Process.monitor(pid)
        Process.exit(pid, :normal)
        receive do
          {:DOWN, ^ref, _, _, _} -> :ok
        after
          timeout -> exit(:timeout)
        end
        :ok
      end

      def init({robot, opts}) do
        {:ok, pid} = Hedwig.Adapters.Connection.connect(@conn, opts)
        {:ok, %Hedwig.Adapter{conn: pid, opts: opts, robot: robot}}
      end

      defoverridable [__before_compile__: 1]
    end
  end

  @doc false
  def start_link({module, conn, adapter}, opts) do
    unless Code.ensure_loaded?(conn) do
      raise """
      could not find #{inspect conn}.

      Please verify you have added #{inspect adapter} as a dependency:

          {#{inspect adapter}, ">= 0.0.0"}

      And remember to recompile Hedwig afterwards by cleaning the current build:

          mix deps.clean hedwig
      """
    end

    GenServer.start_link(module, {self, opts})
  end

  @callback send(pid, term) :: term
  @callback reply(pid, term) :: term
  @callback emote(pid, term) :: term
end
