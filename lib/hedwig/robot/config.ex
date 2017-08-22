defmodule Hedwig.Robot.Config do
  @moduledoc false

  @doc """
  Retrieves the compile-time configuration.
  """
  def compile_config(robot, opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    config  = Application.get_env(otp_app, robot, [])
    adapter = opts[:adapter] || config[:adapter]

    unless adapter do
      raise ArgumentError, "missing :adapter configuration in " <>
                           "config #{inspect otp_app}, #{inspect robot}"
    end

    unless Code.ensure_loaded?(adapter) do
      raise ArgumentError, "adapter #{inspect adapter} was not compiled, " <>
                           "ensure it is correct and it is included as a project dependency"
    end

    {otp_app, adapter, config}
  end

  @doc """
  Retrieves run-time configuration.
  """
  def runtime_config(type, robot, otp_app, custom) do
    if config = Application.get_env(otp_app, robot) do
      config = Keyword.merge(config, custom)
      robot_init(type, robot, config)
    else
      raise ArgumentError,
        "configuration for #{inspect robot} not specified in #{inspect otp_app} environment"
    end
  end

  defp robot_init(type, robot, config) do
    if Code.ensure_loaded?(robot) and function_exported?(robot, :init, 2) do
      robot.init(type, config)
    else
      {:ok, config}
    end
  end
end
