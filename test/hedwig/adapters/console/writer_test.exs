defmodule Hedwig.Adapters.Console.WriterTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  alias Hedwig.Adapters.Console.Writer

  test "console connection prints a banner" do
    output = capture_and_normalize_io fn ->
      Writer.start_link("hedwig")
      Process.sleep(10)
    end

    assert output =~ "Hedwig Console - press Ctrl+C to exit."
    assert output =~ "The console adapter is useful for quickly verifying how your"
    assert output =~ "bot will respond based on the current installed responders"
  end

  test "puts/2" do
    output = capture_and_normalize_io fn ->
      {:ok, pid} = Writer.start_link("hedwig")

      msg = %Hedwig.Message{text: "hello"}
      Writer.puts(pid, msg)
      Process.sleep(10)
    end

    assert output =~ "hedwig> hello"
  end

  test "clear/1" do
    output = capture_io fn ->
      {:ok, pid} = Writer.start_link("hedwig")

      Writer.clear(pid)
      Process.sleep(10)
    end

    assert output =~ "\e[2J\e[H\e[0m"
  end

  defp capture_and_normalize_io(fun) do
    fun |> capture_io() |> strip_ansi()
  end

  defp strip_ansi(string), do: Regex.replace(~r/\e\[[^m]+m/, string, "")
end
