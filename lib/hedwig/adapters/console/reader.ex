defmodule Hedwig.Adapters.Console.Reader do
  @moduledoc false

  use GenServer

  def start_link(user) do
    GenServer.start_link(__MODULE__, {self(), user})
  end

  def init({owner, user}) do
    GenServer.cast(self(), :get_io)
    {:ok, {owner, user}}
  end

  def handle_cast(:get_io, {owner, user}) do
    me = self()
    Task.start fn -> send(me, get_io(user)) end
    {:noreply, {owner, user}}
  end

  def handle_info(:eof, state) do
    {:stop, :normal, state}
  end

  def handle_info({:error, :terminated}, state) do
    {:stop, :normal, state}
  end

  def handle_info({ref, _msg}, state) when is_reference(ref) do
    {:noreply, state}
  end

  def handle_info(text, {owner, user}) when is_binary(text) do
    Kernel.send(owner, {:message, String.trim(text)})
    Process.sleep(200)
    GenServer.cast(self(), :get_io)

    {:noreply, {owner, user}}
  end

  defp prompt(name) do
    [:white, :bright, name, "> ", :normal, :default_color]
  end

  defp get_io(name) do
    name
    |> prompt()
    |> IO.ANSI.format()
    |> IO.gets()
  end
end
