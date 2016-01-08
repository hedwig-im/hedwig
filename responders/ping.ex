defmodule Hedwig.Responders.Ping do
  @moduledoc """
  Responds to 'ping' with 'pong'
  """

  use Hedwig.Responder

  @usage """
  hedwig: ping - Responds with 'pong'
  """
  respond ~r/ping$/i, msg do
    reply msg, "pong"
  end
end
