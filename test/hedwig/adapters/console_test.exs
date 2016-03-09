defmodule Hedwig.Adapters.ConsoleTest do
  use ExUnit.Case

  alias ExUnit.CaptureIO
  alias Hedwig.Adapters.Console.Connection

  test "console connection processes multiple responses" do
    output = capture_and_normalize_io(fn ->
      # run `send_to_adapter` in a new process, pass self() as owner (robot)
      owner = self()
      conn = Task.async(fn ->
        Connection.send_to_adapter("foo", owner, "consoletest", 100)
      end)
      # "we" (the robot) should have received the message "foo"
      assert_receive {:message, "foo"}
      # let's pretend that two responders matched, sending different replies
      send(conn.pid, {:reply, %Hedwig.Message{text: "bar"}})
      send(conn.pid, {:reply, %Hedwig.Message{text: "baaz"}})
      Task.await(conn)
    end)

    # final console output should contain both replies, not necessarily in order
    assert Enum.sort(output) == ["consoletest> baaz", "consoletest> bar"]
  end

  defp capture_and_normalize_io(fun) do
    CaptureIO.capture_io(fun)
    |> strip_ansi()
    |> split_on_eol()
  end

  defp strip_ansi(string), do: Regex.replace(~r/\e\[[^m]+m/, string, "")
  defp split_on_eol(string), do: String.split(string, "\n", trim: true)
end
