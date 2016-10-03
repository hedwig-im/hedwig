defmodule Hedwig do
  @moduledoc """
  Hedwig Application

  ## Starting a robot

      {:ok, pid} = Hedwig.start_robot(MyApp.Robot, name: "alfred")

  ## Stopping a robot

      Hedwig.stop_client(pid)
  """

  use Application

  @doc false
  def start(_type, _args) do
    Hedwig.Supervisor.start_link()
  end

  @doc """
  Starts a robot with the given configuration.
  """
  def start_robot(robot, opts \\ []) do
    Supervisor.start_child(Hedwig.Robot.Supervisor, [robot, opts])
  end

  @doc """
  Stops a robot with the given PID.
  """
  def stop_robot(pid) do
    Supervisor.terminate_child(Hedwig.Robot.Supervisor, pid)
  end

  @doc """
  List all robots.
  """
  def which_robots do
    Supervisor.which_children(Hedwig.Robot.Supervisor)
  end
end
