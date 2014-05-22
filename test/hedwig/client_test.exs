defmodule Hedwig.ClientTest do
  use ExUnit.Case

  alias Hedwig.Client
  alias Hedwig.Stanza

  test "it connects" do
    {:ok, client} = Client.start_link([server: System.get_env("XMPP_SERVER")])
    client |> Client.connect
    client |> Client.stream_start
    client |> Client.start_tls
  end
end
