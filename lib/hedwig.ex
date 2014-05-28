defmodule Hedwig do
  use Application

  def start(_type, opts) do
    Hedwig.Supervisor.start_link(opts)
  end
end
