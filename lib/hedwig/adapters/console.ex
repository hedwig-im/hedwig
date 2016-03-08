defmodule Hedwig.Adapters.Console do
  @moduledoc """
  Hedwig Console Adapter

  The console adapter is useful for testing out responders without a remote
  chat service.

      config :my_app, MyApp.Robot,
        adapter: Hedwig.Adapters.Console,
        ...

  Start your application with `mix run --no-halt` and you will have a console
  interface to your bot.
  """
  use Hedwig.Adapter

  @doc false
  def init({robot, opts}) do
    {:ok, conn} = __MODULE__.Connection.connect(opts)
    {:ok, %{conn: conn, opts: opts, robot: robot}}
  end

  @doc false
  def handle_cast({:send, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  @doc false
  def handle_cast({:reply, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  @doc false
  def handle_cast({:emote, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  @doc false
  def handle_info({:message, ""}, state) do
    {:noreply, state}
  end

  @doc false
  def handle_info({:message, text}, %{robot: robot} = state) do
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
    @moduledoc false

    def connect(opts) do
      {user, 0} = System.cmd("whoami", [])
      clear_screen()
      display_banner()
      Task.start_link(__MODULE__, :loop, [self, String.strip(user), opts[:name]])
    end

    def loop(owner, user, name) do
      user
      |> prompt
      |> IO.ANSI.format
      |> IO.gets
      |> String.strip
      |> send_to_adapter(owner, name)

      loop(owner, user, name)
    end

    defp send_to_adapter(text, owner, name) do
      Kernel.send(owner, {:message, text})
      await(name)
    end

    defp await(name) do
      receive do
        {:reply, resp} ->
          handle_result(resp, name)
          await(name)
      after
        500 -> :ok
      end
    end

    ## IO

    defp print(message) do
      message |> IO.ANSI.format |> IO.puts
    end

    defp prompt(name) do
      [:white, :bright, name, "> ", :normal, :default_color]
    end

    defp clear_screen do
      print [:clear, :home]
    end

    defp handle_result(nil, _name), do: nil
    defp handle_result(msg, name) do
      print prompt(name) ++ [:yellow, msg.text, :default_color]
    end

    defp display_banner do
      print """
      Hedwig Console - press Ctrl+C to exit.

      The console adapter is useful for quickly verifying how your
      bot will respond based on the current installed responders

      """
    end
  end
end
