defmodule Hedwig do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    clients = Application.get_env(:hedwig, :clients, [])
    children = for client <- clients, into: [] do
      worker(Hedwig.Client, [client.jid])
    end

    opts = [strategy: :simple_one_for_one, name: Hedwig.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
