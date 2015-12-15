defmodule Hedwig.ResponderTest do
  use Hedwig.RobotCase

  alias Hedwig.Responder

  test "respond_pattern" do
    robot = %Hedwig.Robot{name: "alfred", aka: nil}

    assert Responder.respond_pattern(~r/hey there/i, robot) ==
      ~r/^\s*[@]?alfred[:,]?\s*(?:hey there)/i

    assert Responder.respond_pattern(~r/this\s*should\s*escape/i, robot) ==
      ~r/^\s*[@]?alfred[:,]?\s*(?:this\s*should\s*escape)/i

    robot = %{robot | aka: "/"}

    assert Responder.respond_pattern(~r/this\s*should\s*escape/i, robot) ==
      ~r/^\s*[@]?(?:alfred[:,]?|\/[:,]?)\s*(?:this\s*should\s*escape)/i
  end

  test "responding to messages", %{adapter: adapter} do
    msg = %{text: "", user: "scrogson"}

    send adapter, {:message, %{msg | text: "this is a test"}}
    assert_receive {:message, %{text: "did someone say test?"}}

    send adapter, {:message, %{msg | text: "alfred do you hear me?"}}
    assert_receive {:message, %{text: "scrogson: loud and clear!"}}

    send adapter, {:message, %{msg | text: "i love cats"}}
    assert_receive {:message, %{text: "scrogson: then why don't you marry cats!?"}}

    send adapter, {:message, %{msg | text: "i like pie"}}
    assert_receive {:message, %{text: "* likes pie too!"}}
  end
end
