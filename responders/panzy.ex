defmodule Hedwig.Responders.Panzy do
  @moduledoc false

  use Hedwig.Responder

  @usage """
  (tired|too? hard|upset|bored) - Replies with 'Panzy!'
  """
  hear ~r/(tired|too? hard|upset|bored)/i, msg do
    reply msg, "Panzy!"
  end

  hear ~r/i like (.*)/i, msg do
    emote msg, "likes #{msg.matches[1]} too!"
  end

  @usage """
  hedwig: hey - Replies with 'sup?'
  """
  respond ~r/hey/i, msg do
    reply msg, "sup?"
  end
end
