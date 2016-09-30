Code.ensure_compiled(Hedwig.Adapters.Test)

defmodule Hedwig.TestRobot do
  use Hedwig.Robot, otp_app: :hedwig, adapter: Hedwig.Adapters.Test

  def handle_connect(%{name: name} = state) do
    Hedwig.Registry.register(name)
    {:ok, state}
  end

  def handle_disconnect(reason, state) do
    {:disconnect, reason, state}
  end

  def handle_in(%Hedwig.Message{} = msg, state) do
    {:dispatch, msg, state}
  end

  def handle_in({:ping, from}, state) do
    Kernel.send(from, :pong)
    {:noreply, state}
  end

  def handle_in(msg, state) do
    super(msg, state)
  end
end
