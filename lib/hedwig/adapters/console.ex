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
  alias Hedwig.Adapters.Console.Connection

  @doc false
  def init({robot, opts}) do
    {:ok, conn} = Connection.start(opts)
    Kernel.send(self(), :connected)
    {:ok, %{conn: conn, opts: opts, robot: robot}}
  end

  @doc false
  def handle_cast({:send, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  @doc false
  def handle_cast({:reply, %{user: user, text: text} = msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, %{msg | text: "#{user}: #{text}"}})
    {:noreply, state}
  end

  @doc false
  def handle_cast({:emote, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  @doc false
  def handle_info({:message, %{"text" => text, "user" => user}}, %{robot: robot} = state) do
    msg = %Hedwig.Message{
      ref: make_ref(),
      robot: robot,
      text: text,
      type: "chat",
      user: user
    }

    Hedwig.Robot.handle_in(robot, msg)

    {:noreply, state}
  end

  def handle_info(:connected, %{robot: robot} = state) do
    :ok = Hedwig.Robot.handle_connect(robot)
    {:noreply, state}
  end
end
