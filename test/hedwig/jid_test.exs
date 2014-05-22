defmodule Hedwig.JidTest do
  use ExUnit.Case, async: true

  alias Hedwig.Jid

  test "it converts structs to binaries" do
    jid = %Jid{user: "jdoe", server: "example.com"}
    assert Jid.to_binary(jid) == "jdoe@example.com"
    jid = %Jid{user: "jdoe", server: "example.com", resource: "library"}
    assert Jid.to_binary(jid) == "jdoe@example.com/library"
  end

  test "it converts binaries into structs" do
    string = "jdoe@example.com"
    assert Jid.to_jid(string) == %Jid{user: "jdoe", server: "example.com"}
    string = "jdoe@example.com/library"
    assert Jid.to_jid(string) == %Jid{user: "jdoe", server: "example.com", resource: "library"}
  end
end
