defmodule Hedwig.ConnTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Hedwig.Client

  setup client do
    {:ok, %{
      jid:      System.get_env("TEST_XMPP_JID"),
      password: System.get_env("TEST_XMPP_PASS"),
      nickname: System.get_env("TEST_XMPP_NICK"),
      resource: System.get_env("TEST_XMPP_RESOURCE") || "hedwig",
     }}
  end

  test "it connects", client do
    {:ok, pid} = Client.start_link(client)
    assert capture_io(:user, fn ->
      :timer.sleep(300)
    end) =~ ~r/#{client.jid} successfully connected/i
  end
end
