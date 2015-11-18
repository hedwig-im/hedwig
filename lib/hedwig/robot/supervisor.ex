defmodule Hedwig.Robot.Supervisor do
  @moduledoc false

  use Supervisor

  @doc """
  Starts the robot supervisor.
  """
  def start_link(robot, otp_app, adapter, opts) do
    name = {:via, :gproc, {:n, :l, {:supervisor, opts[:jid]}}}
    Supervisor.start_link(__MODULE__, {robot, otp_app, adapter, opts}, [name: name])
  end

  def config(robot, otp_app, opts) do
    if config = Application.get_env(otp_app, robot) do
      config
      |> Keyword.put(:otp_app, otp_app)
      |> Keyword.put(:robot, robot)
      |> Keyword.merge(opts)
    else
      raise ArgumentError,
        "configuration for #{inspect robot} not specified in #{inspect otp_app} environment"
    end
  end

  def parse_config(robot, opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    config  = Application.get_env(otp_app, robot, [])
    adapter = opts[:adapter] || config[:adapter]

    unless adapter do
      raise ArgumentError, "missing `:adapter` configuration for " <>
                           "#{inspect otp_app}, #{inspect robot}"
    end

    unless Code.ensure_loaded?(adapter) do
      raise ArgumentError, "adapter #{inspect adapter} was not compiled, " <>
                           "ensure it is correct and it is included as a " <>
                           "project dependency."
    end

    {otp_app, adapter, config}
  end

  def init({robot, otp_app, adapter, opts}) do
    opts = config(robot, otp_app, opts) |> Keyword.delete(:name)
    supervise([supervisor(adapter, [robot, opts])], strategy: :one_for_one)
  end
end
