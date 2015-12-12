defmodule Hedwig.Adapters.Connection do
  @moduledoc """
  Behaviour for adapters which rely on connections.

  In order to use a connection, adapter developers need only implement
  a single callback: `connect/1` defined in this module.
  """

  use Behaviour

  @doc """
  Connects to the underlying message protocol.

  Should return a process which is linked to
  the caller process or an error.
  """
  @callback connect(Keyword.t) :: {:ok, pid} | {:error, term}

  @doc """
  Executes the connect in the given module.
  """
  def connect(module, opts) do
    case module.connect(opts) do
      {:ok, _}    = conn  -> conn
      {:error, _} = error -> error
    end
  end

  @doc """
  Shutdown the given connection `pid`.

  If `pid` does not exit within `timeout`, it is killed, or it is killed
  immediately if `:brutal_kill`.
  """
  @spec shutdown(pid, timeout | :brutal_kill) :: :ok
  def shutdown(pid, timeout \\ 5_000)

  def shutdown(pid, :brutal_kill) do
    ref = Process.monitor(pid)
    Process.exit(pid, :kill)
    receive do
      {:DOWN, ^ref, _, _, _} -> :ok
    end
  end

  def shutdown(pid, timeout) do
    ref = Process.monitor(pid)
    Process.exit(pid, :shutdown)
    receive do
      {:DOWN, ^ref, _, _, _} -> :ok
    after
      timeout ->
        Process.exit(pid, :kill)
        receive do
          {:DOWN, ^ref, _, _, _} -> :ok
        end
    end
  end
end
