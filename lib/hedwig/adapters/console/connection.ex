defmodule Hedwig.Adapters.Console.Connection do
  @moduledoc false
  use GenServer

  alias Hedwig.Adapters.Console.{Connection, Reader, Writer}

  defstruct name: nil, owner: nil, reader: nil, user: nil, writer: nil

  def start(opts) do
    name = Keyword.get(opts, :name)
    user = Keyword.get(opts, :user, get_system_user())

    GenServer.start(__MODULE__, {self(), name, user})
  end

  def init({owner, name, user}) do
    GenServer.cast(self(), :after_init)
    {:ok, %Connection{name: name, owner: owner, user: user}}
  end

  def handle_cast(:after_init, %{name: name, user: user} = state) do
    {:ok, writer} = Writer.start_link(name)
    {:ok, reader} = Reader.start_link(user)
    {:noreply, %{state | reader: reader, writer: writer}}
  end

  def handle_info({:reply, text}, %{writer: writer} = state) do
    Writer.puts(writer, text)
    {:noreply, state}
  end

  @doc false
  def handle_info({:message, "clear"}, %{writer: writer} = state) do
    Writer.clear(writer)
    {:noreply, state}
  end

  def handle_info({:message, text}, %{owner: owner, user: user} = state) do
    Kernel.send(owner, {:message, %{"text" => text, "user" => user}})
    {:noreply, state}
  end

  defp get_system_user do
    System.cmd("whoami", [])
    |> elem(0)
    |> String.trim()
  end
end
