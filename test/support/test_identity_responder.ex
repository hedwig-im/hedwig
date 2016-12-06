defmodule TestIdentityResponder do
  use Hedwig.Responder

  @bot_name "Cool Bot"
  @bot_emoji ":sunglasses:"

  @usage """
  (whats up) - the sky!
  """
  hear ~r/whats up/i, msg do
    send msg, "the sky!"
  end
end
