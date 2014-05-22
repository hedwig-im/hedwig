defmodule Hedwig.SocketTest do
  use ExUnit.Case, async: true

  test "it returns a socket" do
    {:ok, socket} = Hedwig.Socket.connect "localhost"
    assert is_port(socket)
  end
end
