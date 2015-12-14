defmodule Hedwig.ResponderTest do
  use ExUnit.Case, async: true

  alias Hedwig.Responder

  defmodule TestResponder do
    use Hedwig.Responder

    hear ~r/this is a test/i, msg do
      send msg, "did someone say test?"
    end

    hear ~r/i love (\w+)/i, msg do
      reply msg, "then why don't you marry #{msg.matches[1]}!?"
    end

    hear ~r/i like (?<subject>\w+)/i, msg do
      emote msg, "likes #{msg.matches["subject"]} too!"
    end

    respond ~r/do you hear me\?/i, msg do
      reply msg, "loud and clear!"
    end
  end

  setup do
    config = [name: "alfred", aka: "/", responders: [{TestResponder, []}]]
    Application.put_env(:hedwig, Hedwig.TestRobot, config)
    {:ok, robot} = Hedwig.start_robot(Hedwig.TestRobot)

    current = self
    adapter = :sys.get_state(robot).adapter
    :sys.replace_state(adapter, fn state -> %{state | conn: current} end)

    {:ok, adapter: adapter, robot: robot}
  end

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
