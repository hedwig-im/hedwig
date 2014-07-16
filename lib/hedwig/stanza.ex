defmodule Hedwig.Stanza do
  use Hedwig.XML

  def to_xml(record), do: :exml.to_binary(record)

  def start_stream(server, xmlns \\ ns_jabber_client) do
    xmlstreamstart(name: "stream:stream",
      attrs: [
        {"to", server},
        {"version", "1.0"},
        {"xml:lang", "en"},
        {"xmlns", xmlns},
        {"xmlns:stream", ns_xmpp}
      ])
  end

  def end_stream do
    xmlstreamend(name: "stream:stream")
  end

  def start_tls do
    xmlel(name: "starttls",
      attrs: [
        {"xmlns", ns_tls}
      ])
  end

  def compress(method) do
    xmlel(name: "compress",
      attrs: [
        {"xmlns", ns_compress}
      ],
      children: [
        xmlel(name: "method", children: [:exml.escape_cdata(method)])
      ])
  end

  def iq(type, body) do
    xmlel(name: "iq",
      attrs: [
        {"type", type},
        {"id", id}
      ],
      children: body)
  end
  def id do
    :crypto.rand_bytes(2) |> Base.encode16(case: :lower)
  end
end
