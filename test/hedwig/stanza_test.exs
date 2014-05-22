defmodule Hedwig.StanzaTest do
  use ExUnit.Case, async: true
  use Hedwig.XML

  alias Hedwig.Stanza

  test "stream_start with default xmlns" do
    assert Stanza.stream_start("im.wonderland.lit") |> :exml.to_binary ==
      "<stream:stream xmlns:stream='http://etherx.jabber.org/streams' xmlns='jabber:client' xml:lang='en' version='1.0' to='im.wonderland.lit'>"
  end

  test "stream_start with 'jabber:server' xmlns" do
    assert Stanza.stream_start("im.wonderland.lit", ns_jabber_server) |> :exml.to_binary ==
      "<stream:stream xmlns:stream='http://etherx.jabber.org/streams' xmlns='jabber:server' xml:lang='en' version='1.0' to='im.wonderland.lit'>"
  end

  test "stream_end" do
    assert Stanza.stream_end |> :exml.to_binary == "</stream:stream>"
  end

  test "start_tls" do
    assert Stanza.start_tls |> :exml.to_binary ==
      "<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>"
  end
end
