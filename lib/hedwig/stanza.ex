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

  def auth(mechanism, body) do
    xmlel(name: "auth",
      attrs: [
        {"xmlns", ns_sasl},
        {"mechanism", mechanism}
      ],
      children: base64_cdata(body))
  end

  def bind(resource) do
    body = xmlel(name: "bind",
      attrs: [
        {"xmlns", ns_bind},
      ],
      children: [
        xmlel(name: "resource",
          children: xmlcdata(content: resource))
      ])
    iq("set", body)
  end

  def session do
    body = xmlel(name: "session",
      attrs: [
        {"xmlns", ns_session}
      ])
    iq("set", body)
  end

  def presence do
    xmlel(name: "presence")
  end

  def iq(type, body) do
    xmlel(name: "iq",
      attrs: [
        {"type", type},
        {"id", id}
      ],
      children: body)
  end

  def iq(to, type, body) do
  end

  def base64_cdata(payload) do
    [xmlcdata(content: Base.encode64(payload))]
  end

  def id do
    :crypto.rand_bytes(2) |> Base.encode16(case: :lower)
  end
end
