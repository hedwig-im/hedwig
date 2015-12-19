defmodule Hedwig.Responders.HelpTest do
  use Hedwig.RobotCase

  @tag start_robot: true, name: "alfred"
  test "help - displays the usage for all installed responders", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "alfred help"}}
    assert_receive {:message, %{text: text}}
    assert String.contains?(text, "Displays all help commands that match <query>")
  end

  @tag start_robot: true, name: "alfred"
  test "help <query> - displays the usage for responders that match query", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "alfred help test"}}
    assert_receive {:message, %{text: text}}
    assert text == "(this is a test) - did someone say test?"
  end
end
