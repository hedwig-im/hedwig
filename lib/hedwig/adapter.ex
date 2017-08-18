defmodule Hedwig.Adapter do
  @moduledoc """
  Hedwig Adapter Behaviour

  An adapter is the interface to the service a bot runs on. To implement an
  adapter you will need to translate messages from the service to the
  `Hedwig.Message` struct and call `Hedwig.Robot.handle_in(robot, msg)`.
  """

  @type robot :: pid
  @type state :: term
  @type opts  :: any
  @type msg   :: Hedwig.Message.t

  @doc false
  defmacro __using__(_opts) do
    quote do
      use GenServer

      import Kernel, except: [send: 2]

      Module.register_attribute(__MODULE__, :hedwig_adapter, persist: true)
      Module.put_attribute(__MODULE__, :hedwig_adapter, true)

      @doc false
      def start_link(robot, opts) do
        Hedwig.Adapter.start_link(__MODULE__, opts)
      end

      @doc false
      def stop(pid, timeout \\ 5000) do
        ref = Process.monitor(pid)
        Process.exit(pid, :normal)
        receive do
          {:DOWN, ^ref, _, _, _} -> :ok
        after
          timeout -> exit(:timeout)
        end
        :ok
      end
    end
  end

  @doc false
  def start_link(module, opts) do
    GenServer.start_link(module, {self(), opts})
  end

  @doc false
  def send(pid, %Hedwig.Message{} = msg) do
    GenServer.cast(pid, {:send, msg})
  end

  @doc false
  def reply(pid, %Hedwig.Message{} = msg) do
    GenServer.cast(pid, {:reply, msg})
  end

  @doc false
  def emote(pid, %Hedwig.Message{} = msg) do
    GenServer.cast(pid, {:emote, msg})
  end
end
