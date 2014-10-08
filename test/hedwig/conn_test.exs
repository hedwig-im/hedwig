defmodule Hedwig.ConnTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Hedwig.Client

  # TODO: Figure out how to really test this better.
  test "it connects" do
    client = Client.client_for(System.get_env("XMPP_JID"))
    assert capture_io(:user, fn ->
      :timer.sleep(500)
    end) =~ ~r/#{client.jid} successfully connected/i
  end
end
