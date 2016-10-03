defmodule Hedwig.Adapters.Console.Writer do
  @moduledoc false
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, {self(), name})
  end

  def puts(pid, msg) do
    GenServer.cast(pid, {:puts, msg})
  end

  def clear(pid) do
    GenServer.cast(pid, :clear)
  end

  def init({owner, name}) do
    GenServer.cast(self(), :after_init)
    {:ok, {owner, name}}
  end

  def handle_cast(:after_init, state) do
    clear_screen()
    display_banner()
    {:noreply, state}
  end

  def handle_cast(:clear, {owner, name}) do
    clear_screen()
    {:noreply, {owner, name}}
  end

  def handle_cast({:puts, msg}, {owner, name}) do
    handle_result(msg, name)
    {:noreply, {owner, name}}
  end

  defp print(message) do
    message
    |> IO.ANSI.format()
    |> IO.puts()
  end

  defp handle_result(msg, name) do
    print prompt(name) ++ [:normal, :default_color, msg.text]
  end

  defp prompt(name) do
    [:yellow, name, "> ", :default_color]
  end

  defp clear_screen do
    print [:clear, :home]
  end

  defp display_banner do
    print """
    Hedwig Console - press Ctrl+C to exit.

    The console adapter is useful for quickly verifying how your
    bot will respond based on the current installed responders

    """
  end
end
