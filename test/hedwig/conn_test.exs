defmodule Hedwig.ConnTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Hedwig.Conn
  alias Hedwig.Client

  test "it connects" do
    client = System.get_env("XMPP_JID")
    |> Client.client_for
    |> Client.to_struct

    assert capture_io(:user, fn ->
      Client.start_link(client)
      :timer.sleep(500)
    end) =~ ~r/#{client.jid} successfully connected/
  end
end
