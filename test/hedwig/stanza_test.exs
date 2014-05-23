defmodule Hedwig.StanzaTest do
  use ExUnit.Case, async: true
  use Hedwig.XML

  alias Hedwig.Stanza

  test "start_stream with default xmlns" do
    assert Stanza.start_stream("im.wonderland.lit") |> :exml.to_binary ==
      "<stream:stream xmlns:stream='http://etherx.jabber.org/streams' xmlns='jabber:client' xml:lang='en' version='1.0' to='im.wonderland.lit'>"
  end

  test "start_stream with 'jabber:server' xmlns" do
    assert Stanza.start_stream("im.wonderland.lit", ns_jabber_server) |> :exml.to_binary ==
      "<stream:stream xmlns:stream='http://etherx.jabber.org/streams' xmlns='jabber:server' xml:lang='en' version='1.0' to='im.wonderland.lit'>"
  end

  test "end_stream" do
    assert Stanza.end_stream |> :exml.to_binary == "</stream:stream>"
  end

  test "start_tls" do
    assert Stanza.start_tls |> :exml.to_binary ==
      "<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>"
  end
end
