defmodule Hedwig.Adapter do
  @moduledoc """
  Hedwig Adapter Behaviour

  An adapter is the interface to the service your bot runs on. To implement an
  adapter you will need to translate messages from the service to the
  `Hedwig.Message` struct and call `Hedwig.Robot.handle_message(robot, msg)`.
  """

  use Behaviour

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [send: 2]

      @behaviour Hedwig.Adapter

      def send(pid, %Hedwig.Message{} = msg) do
        GenServer.cast(pid, {:send, msg})
      end

      def reply(pid, %Hedwig.Message{} = msg) do
        GenServer.cast(pid, {:reply, msg})
      end

      def emote(pid, %Hedwig.Message{} = msg) do
        GenServer.cast(pid, {:emote, msg})
      end

      @doc false
      def start_link(robot, opts) do
        Hedwig.Adapter.start_link(__MODULE__, opts)
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

      @doc false
      defmacro __before_compile__(_env) do
        :ok
      end

      defoverridable [__before_compile__: 1, send: 2, reply: 2, emote: 2]
    end
  end

  @doc false
  def start_link(module, opts) do
    GenServer.start_link(module, {self, opts})
  end

  @callback send(pid, Hedwig.Message.t) :: term
  @callback reply(pid, Hedwig.Message.t) :: term
  @callback emote(pid, Hedwig.Message.t) :: term
end
