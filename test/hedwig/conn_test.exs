defmodule Hedwig.ConnTest do

  use ExUnit.Case, async: true
  use UserHelper

  setup do
    capture_log fn -> :ejabberd.start end

    bob = setup_user("bob")

    on_exit fn ->
      capture_log fn ->
        teardown_user("bob")
      end
      File.rm_rf("mnesia")
    end

    {:ok, bob: bob}
  end

  test "it connects", %{bob: bob} do
    output = capture_log fn ->
      {:ok, _pid} = Hedwig.Client.start_link(bob)
      :timer.sleep(300)
    end
    assert output =~ ~r/#{bob.jid} successfully connected/i
  end
end
