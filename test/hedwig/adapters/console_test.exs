defmodule Hedwig.Adapters.ConsoleTest do
  use ExUnit.Case

  alias ExUnit.CaptureIO
  alias Hedwig.Adapters.Console.Connection

  test "console connection processes multiple responses" do
    output = capture_and_normalize_io(fn ->
      conn = spawn_link(Connection, :send_to_adapter, ["foo", self, "consoletest"])
      assert_receive {:message, "foo"}
      send(conn, {:reply, %Hedwig.Message{text: "bar"}})
      send(conn, {:reply, %Hedwig.Message{text: "baaz"}})
      :timer.sleep(500)
    end)

    assert output == ["consoletest> bar", "consoletest> baaz"]
  end

  defp capture_and_normalize_io(fun) do
    CaptureIO.capture_io(fun)
    |> strip_ansi()
    |> split_on_eol()
  end

  defp strip_ansi(string), do: Regex.replace(~r/\e\[[^m]+m/, string, "")
  defp split_on_eol(string), do: String.split(string, "\n", trim: true)
end
