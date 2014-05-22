defmodule Hedwig.Stanza do
  use Hedwig.XML

  def stream_start(server, xmlns \\ ns_jabber_client) do
    xmlstreamstart(name: "stream:stream",
      attrs: [
        {"to", server},
        {"version", "1.0"},
        {"xml:lang", "en"},
        {"xmlns", xmlns},
        {"xmlns:stream", ns_xmpp}
      ])
  end

  def stream_end do
    xmlstreamend(name: "stream:stream")
  end

  def start_tls do
    xmlel(name: "starttls",
    attrs: [
      {"xmlns", ns_tls}
    ])
  end
end
