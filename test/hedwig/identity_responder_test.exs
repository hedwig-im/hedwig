defmodule Hedwig.IdentityResponderTest do
  use Hedwig.RobotCase

  @tag start_robot: true, name: "alfred"
  test "responding with bot identity", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "whats up"}}
    assert_receive {:message, 
      %{text: "the sky!", private: %{identity: %{name: "Cool Bot"}}}}
  end

  test "bot_identity" do
    assert TestIdentityResponder.bot_identity(nil, nil) ==
      %{name: "Cool Bot", emoji: ":sunglasses:", thumbnail: nil}
  end
end
