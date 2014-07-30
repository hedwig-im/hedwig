defmodule Hedwig.ConnTest do
  use ExUnit.Case, async: true

  alias Hedwig.Conn
  alias Hedwig.Client

  test "it connects" do
    client = System.get_env("XMPP_JID")
    |> Client.client_for
    |> Client.to_struct

    Conn.start(client)
  end
end
