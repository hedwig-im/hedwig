defmodule Hedwig.Adapters.Console do
  use Hedwig.Adapter

  ## Adapter API

  def send(pid, msg) do
    GenServer.cast(pid, {:reply, msg})
  end

  def reply(pid, msg) do
    GenServer.cast(pid, {:reply, msg})
  end

  def emote(pid, msg) do
    GenServer.cast(pid, {:emote, msg})
  end

  ## Callbacks

  def handle_cast({:send, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  def handle_cast({:reply, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  def handle_cast({:emote, %{text: text} = msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  def handle_info({:message, ""}, state) do
    {:noreply, state}
  end

  def handle_info({:message, text}, %{robot: robot, conn: conn} = state) do
    {user, 0} = System.cmd("whoami", [])

    msg = %Hedwig.Message{
      adapter: {__MODULE__, self},
      ref: make_ref(),
      text: text,
      type: "chat",
      user: String.strip(user)
    }

    Hedwig.Robot.handle_message(robot, msg)

    {:noreply, state}
  end

  defmodule Connection do

    def connect(opts) do
      {user, 0} = System.cmd("whoami", [])

      IO.puts [IO.ANSI.clear, IO.ANSI.home]
      display_banner()
      Task.start_link(__MODULE__, :loop, [self, String.strip(user), opts[:name]])
    end

    def loop(owner, user, name) do
      user
      |> prompt
      |> IO.gets
      |> String.strip
      |> call_adapter(owner, name)

      loop(owner, user, name)
    end

    defp call_adapter(text, owner, name) do
      send(owner, {:message, text})
      await(name)
    end

    defp await(name) do
      receive do
        {:reply, resp} ->
          handle_result(resp, name)
      after
        1_000 -> :ok
      end
    end

    ## IO

    defp prompt(name) do
      import IO.ANSI
      [white, bright, name, "> ", normal, default_color]
    end

    defp handle_result(nil, _name), do: nil
    defp handle_result(msg, name) do
      import IO.ANSI
      IO.puts prompt(name) ++ [yellow, msg.text, default_color]
    end

    defp display_banner do
      IO.puts "Hedwig Console - press Ctrl+C to exit.\r\n"
      IO.puts "The console adapter is useful for quickly verifying how your\r"
      IO.puts "bot will respond based on the current installed responders.\r\n"
    end
  end
end
