defmodule Hedwig do
  use Application.Behaviour

  def start(_type, opts) do
    Hedwig.Supervisor.start_link(opts)
  end
end
