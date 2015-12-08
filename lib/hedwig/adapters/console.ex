defmodule Hedwig.Adapters.Console do
  use Hedwig.Adapter

  def send(pid, msg) do
    Kernel.send(pid, {:send, msg})
  end

  def reply(pid, msg) do
    Kernel.send(pid, msg)
  end

  def handle_call({:reply, msg}, _from, state) do
    Kernel.send(state.conn, msg)
    {:reply, :ok, state}
  end

  def handle_info({:message, ""}, state) do
    {:noreply, state}
  end

  def handle_info({:message, text}, %{robot: robot} = %{conn: conn} = state) do
    {user, 0} = System.cmd("whoami", [])

    ref = make_ref()
    msg = %Hedwig.Message{
      adapter: {__MODULE__, self},
      ref: ref,
      text: text,
      type: "chat",
      user: String.strip(user)
    }

    Hedwig.Robot.handle_message(robot, msg)

    msg =
      receive do
        {:reply, %Hedwig.Message{ref: ^ref}} = reply ->
          Kernel.send(conn, reply)
        {:reply, nil} = reply ->
          Kernel.send(conn, reply)
      after
        5_000 ->
          Kernel.send(conn, {:reply, nil})
      end

    {:noreply, state}
  end

  defmodule Connection do

    def connect(opts) do
      IO.puts [IO.ANSI.clear, IO.ANSI.home]
      Task.start_link(__MODULE__, :loop, [self, opts[:name]])
    end

    def loop(owner, name) do
      name
      |> prompt
      |> IO.gets
      |> String.strip
      |> call_adapter(owner)

      loop(owner, name)
    end

    defp call_adapter(text, owner) do
      send(owner, {:message, text})
      await()
    end

    defp await do
      receive do
        {:reply, resp} ->
          handle_result(resp)
      after
        5_000 ->
          :ok
      end
    end

    defp prompt(name) do
      import IO.ANSI
      [white, bright, name, "> ", normal, default_color]
    end

    defp handle_result(nil), do: nil
    defp handle_result(msg) do
      import IO.ANSI
      IO.puts [yellow, msg.text, default_color]
    end
  end
end
