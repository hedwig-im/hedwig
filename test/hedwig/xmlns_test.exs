defmodule Hedwig.XMLNSTest do
  use ExUnit.Case, async: true

  import Hedwig.XMLNS

  test "it provides XML namespaces" do
    assert ns_xml == "http://www.w3.org/XML/1998/namespace"
    assert ns_xmpp == "http://etherx.jabber.org/streams"
  end
end
