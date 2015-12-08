defmodule Hedwig.Responders.Panzy do
  @moduledoc """
  Says 'Panzy!' whenever someone is being a whiner.
  """
  use Hedwig.Responder

  @usage """
  <text> (tired|too hard|to hard|upset|bored) - Replies with 'Panzy!'
  """
  hear ~r/tired|too? hard|upset|bored/i, msg do
    %{msg | text: "Panzy!"}
  end

  @usage """
  tell me about <subject>
  """
  hear ~r/tell me about (?<subject>.*)/i, msg do
    %{msg | text: "#{msg.matches["subject"]} are cool"}
  end

  @usage """
  hey
  """
  respond ~r/hey/i, msg do
    %{msg | text: "sup?"}
  end
end
