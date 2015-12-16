defmodule TestResponder do
  use Hedwig.Responder

  @usage """
  (this is a test) - did someone say test?
  """
  hear ~r/this is a test/i, msg do
    send msg, "did someone say test?"
  end

  @usage """
  (i love <subject>) - Relies with "then why don't you marry <subject>!?"
  """
  hear ~r/i love (\w+)/i, msg do
    reply msg, "then why don't you marry #{msg.matches[1]}!?"
  end

  @usage """
  (i like <subject>) - Emotes "likes <subject> too!"
  """
  hear ~r/i like (?<subject>\w+)/i, msg do
    emote msg, "likes #{msg.matches["subject"]} too!"
  end

  @usage """
  hedwig do you hear me? - Replies with "loud and clear!"
  """
  respond ~r/do you hear me\?/i, msg do
    reply msg, "loud and clear!"
  end

  @usage """
  a random example
  """
  hear ~r/randomness/i, msg do
    send msg, random(Enum.to_list(1..1000))
  end
end
