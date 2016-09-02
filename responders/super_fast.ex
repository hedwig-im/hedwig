defmodule Hedwig.Responders.SuperFast do
  @moduledoc false

  use Hedwig.Responder

  @links [
    "http://media.tenor.co/images/76708e6143b45195612c69086358c138/raw",
    "http://graphics.desivalley.com/wp-content/uploads/2010/08/superfast-cat.gif"
  ]

  @usage """
  that was superfast - Display a fast gif animation.
  """

  hear ~r/that was superfast(!)?/i, msg do
    reply msg, random(@links)
  end
end
