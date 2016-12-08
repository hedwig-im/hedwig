defmodule Hedwig.ResponderTest do
  use Hedwig.RobotCase

  alias Hedwig.Responder

  test "bot_identity" do
    assert TestResponder.bot_identity(nil, nil) ==
      %{name: nil, thumbnail: nil, emoji: nil}
  end

  test "respond_pattern" do
    assert Responder.respond_pattern(~r/hey there/i, "alfred", nil) ==
      ~r/^\s*[@]?alfred[:,]?\s*(?:hey there)/i

    assert Responder.respond_pattern(~r/this\s*should\s*escape/i, "alfred", nil) ==
      ~r/^\s*[@]?alfred[:,]?\s*(?:this\s*should\s*escape)/i

    assert Responder.respond_pattern(~r/this\s*should\s*escape/i, "alfred", "/") ==
      ~r/^\s*[@]?(?:alfred[:,]?|\/[:,]?)\s*(?:this\s*should\s*escape)/i
  end

  @tag start_robot: true, name: "alfred"
  test "responding to messages", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "this is a test"}}
    assert_receive {:message, %{text: "did someone say test?"}}

    send adapter, {:message, %{msg | text: "alfred do you hear me?"}}
    assert_receive {:message, %{text: "testuser: loud and clear!"}}

    send adapter, {:message, %{msg | text: "i love cats"}}
    assert_receive {:message, %{text: "testuser: then why don't you marry cats!?"}}

    send adapter, {:message, %{msg | text: "i like pie"}}
    assert_receive {:message, %{text: "* likes pie too!"}}

    send adapter, {:message, %{msg | text: "randomness"}}
    assert_receive {:message, %{text: text}}
    assert text in 1..1000

    send adapter, {:message, %{msg | text: "promote me"}}
    assert_receive {:message, %{text: "yessir", private: %{rank: "captain"}}}
  end
end
