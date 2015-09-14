defmodule Hedwig do
  @moduledoc """
  Hedwig Application

  ## Starting a client

      Hedwig.start_client(%{
        jid: "alice@wonderland.lit",
        password: "password",
        nickname: "alice",
        rooms: ["lobby@conference.wonderland.lit"],
        handlers: [{Hedwig.Handlers.Help, %{}}, {Hedwig.Handlers.Panzy, %{}}]
      })

  ## Stopping a client

      pid = Hedwig.whereis("alice@wonderland.lit")
      Hedwig.stop_client(pid)
  """

  use Application

  @doc false
  def start(_type, _args) do
    Hedwig.Supervisor.start_link()
  end

  @doc """
  Starts a client with the given configuration.
  """
  def start_client(config) do
    Supervisor.start_child(Hedwig.Client.Supervisor, [config])
  end

  @doc """
  Stops a client with the given PID.
  """
  def stop_client(pid) do
    Supervisor.terminate_child(Hedwig.Client.Supervisor, pid)
  end

  @doc """
  List all clients.
  """
  def which_clients do
    Supervisor.which_children(Hedwig.Client.Supervisor)
  end

  @doc """
  Find a client PID by JID through the `Hedwig.Registry`.
  """
  def whereis(jid) do
    Hedwig.Registry.whereis(jid)
  end
end
