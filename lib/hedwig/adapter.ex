defmodule Hedwig.Adapter do
  @moduledoc """
  """

  @doc false
  defmacro __using__(adapter) do
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
        {:ok, _} = Application.ensure_all_started(@adapter)
        Hedwig.Adapter.start_link(@conn, @adapter, robot, opts)
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
        Application.stop(@adapter)
        :ok
      end
    end
  end

  @doc false
  def start_link(conn, adapter, _robot, opts) do
    unless Code.ensure_loaded?(conn) do
      raise """
      could not find #{inspect conn}.

      Please verify you have added #{inspect adapter} as a dependency:

          {#{inspect adapter}, ">= 0.0.0"}

      And remember to recompile Hedwig afterwards by cleaning the current build:

          mix deps.clean hedwig
      """
    end

    conn.connect(opts)
  end

  @type robot   :: Hedwig.Robot.t
  @type options :: Keyword.t

  #@callback send(pid, envelop)

  @doc """
  The callback invoked in case the adapter needs to inject code.
  """
  @macrocallback __before_compile__(Macro.Env.t) :: Macro.t

  @callback start_link(robot, options) ::
            {:ok, pid} | {:error, {:already_started, pid}} | {:error, term}
end
