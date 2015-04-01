defmodule Hedwig.JidTest do
  use ExUnit.Case, async: true

  alias Hedwig.JID

  doctest Hedwig.JID

  test "String.Chars protocol converts structs to binaries" do
    jid = %JID{server: "example.com"}
    assert to_string(jid) == "example.com"

    jid = %JID{user: "jdoe", server: "example.com"}
    assert to_string(jid) == "jdoe@example.com"

    jid = %JID{user: "jdoe", server: "example.com", resource: "library"}
    assert to_string(jid) == "jdoe@example.com/library"
  end

  test "bare returns a JID without a resource" do
    jid = %JID{user: "jdoe", server: "example.com", resource: "library"}
    assert JID.bare(jid) == "jdoe@example.com"
    assert JID.bare("jdoe@example.com/library") == "jdoe@example.com"
    assert JID.bare("jdoe@example.com") == "jdoe@example.com"
  end

  test "it converts binaries into structs" do
    string = "jdoe@example.com"
    assert JID.parse(string) == %JID{user: "jdoe", server: "example.com"}

    string = "jdoe@example.com/library"
    assert JID.parse(string) == %JID{user: "jdoe", server: "example.com", resource: "library"}

    string = "jdoe@example.com/jdoe@example.com/resource"
    assert JID.parse(string) == %JID{user: "jdoe", server: "example.com", resource: "jdoe@example.com/resource"}

    string = "example.com"
    assert JID.parse(string) == %JID{user: "", server: "example.com", resource: ""}
  end
end
