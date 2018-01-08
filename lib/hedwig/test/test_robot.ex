Code.ensure_compiled(Hedwig.Adapters.Test)

defmodule Hedwig.TestRobot do
  use Hedwig.Robot, otp_app: :hedwig, adapter: Hedwig.Adapters.Test

  @moduledoc false

  def handle_connect(%{name: name} = state) do
    if :undefined == :global.whereis_name(name) do
      :yes = :global.register_name(name, self())
    end

    {:ok, state}
  end

  def handle_disconnect(:error, state),
    do: {:disconnect, :normal, state}
  def handle_disconnect(:reconnect, state),
    do: {:reconnect, state}
  def handle_disconnect({:reconnect, timer}, state),
    do: {:reconnect, timer, state}

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
