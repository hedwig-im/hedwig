defmodule Hedwig.TestRobot do
  use Hedwig.Robot,
    otp_app: :hedwig,
    adapter: Hedwig.Adapters.Test

  def start_link(args) do
    Hedwig.Robot.start_link(__MODULE__, args, name: {:global, args[:name]})
  end

  def init(_, config) do
    {:ok, config}
  end

  def handle_connect(state) do
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
