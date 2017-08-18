defmodule Hedwig.Application do
  use Application

  @doc false
  def start(_type, _args) do
    Hedwig.Supervisor.start_link()
  end
end
