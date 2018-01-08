defmodule Hedwig.Responder.Supervisor do
  @moduledoc false

  def start_link do
    import Supervisor.Spec, warn: false

    children = [
      worker(Hedwig.Responder, [], restart: :transient)
    ]

    Supervisor.start_link(children, strategy: :simple_one_for_one)
  end
end
