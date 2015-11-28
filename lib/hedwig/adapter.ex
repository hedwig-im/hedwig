defmodule Hedwig.Adapter do
  @moduledoc """
  """

  defstruct conn: nil,
            robot: nil

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

      def send(pid, msg) do
        GenServer.call(pid, {:send, msg})
      end

      def init({robot, opts}) do
        {:ok, pid} = Hedwig.Adapters.Connection.connect(@conn, opts)
        {:ok, %Hedwig.Adapter{conn: pid, robot: robot}}
      end

      def handle_call({:send, msg}, _from, %{conn: conn} = state) do
        __MODULE__.send(conn, msg)
        {:reply, :ok, state}
      end

      def handle_info(msg, %{robot: robot} = state) do
        Kernel.send(robot, msg)
        {:noreply, state}
      end
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
end
