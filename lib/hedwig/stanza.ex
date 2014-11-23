defmodule Hedwig.Stanza do

  @moduledoc """
  Provides convenience functions for building XMPP stanzas.
  """

  use Hedwig.XML

  alias Hedwig.JID
  alias Hedwig.Stanzas.Presence

  @doc """
  Converts an `exml` record to an XML binary string.
  """
  def to_xml(record) when Record.is_record(record), do: :exml.to_binary(record)
  def to_xml(%Presence{} = pres) do
    xmlel(name: "presence",
      attrs: [
        {"to", JID.bare(pres.to)},
        {"type", pres.type}
      ]
    ) |> to_xml
  end

  @doc """
  Starts an XML stream.

  ## Example

      iex> stanza = Hedwig.Stanza.start_stream("im.capulet.lit")
      {:xmlstreamstart, "stream:stream",
       [{"to", "im.capulet.lit"}, {"version", "1.0"}, {"xml:lang", "en"},
         {"xmlns", "jabber:client"},
         {"xmlns:stream", "http://etherx.jabber.org/streams"}]}

      iex> Hedwig.Stanza.to_xml(stanza)
      "<stream:stream
         xmlns:stream='http://etherx.jabber.org/streams'
         version='1.0'
         xmlns='jabber:client'
         to='im.capulet.lit'
         xml:lang='en'
         xmlns:xml='http://www.w3.org/XML/1998/namespace'>"
  """
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

  @doc """
  Ends the XML stream

  ## Example
      iex> stanza = Hedwig.Stanza.end_steam
      {:xmlel, "stream:stream", [], []}
      iex> Hedwig.Stanza.to_xml(stanza)
      "</stream:stream>"
  """
  def end_stream, do: xmlstreamend(name: "stream:stream")

  @doc """
  Generates the XML to start TLS.

  ## Example
      iex> stanza = Hedwig.Stanza.start_tls
      {:xmlel, "starttls", [{"xmlns", "urn:ietf:params:xml:ns:xmpp-tls"}], []}
      iex> Hedwig.Stanza.to_xml(stanza)
      "<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>"
  """
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

  def auth(mechanism), do: auth(mechanism, [])
  def auth(mechanism, body) do
    xmlel(name: "auth",
      attrs: [
        {"xmlns", ns_sasl},
        {"mechanism", mechanism}
      ],
      children: body)
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
    xmlel(name: "iq", attrs: [{"type", type}, {"id", id}], children: body)
  end

  def iq(to, type, body) do
    iq = iq(type, body)
    xmlel(iq, attrs: [{"to", to}|xmlel(iq, :attrs)])
  end

  def get_roster do
    iq("get", xmlel(name: "query", attrs: [{"xmlns", ns_roster}]))
  end

  def get_vcard(to) do
    iq(to, "get", xmlel(name: "vCard", attrs: [{"xmlns", ns_vcard}]))
  end

  def disco_info(to) do
    iq(to, "get", xmlel(name: "query", attrs: [{"xmlns", ns_disco_info}]))
  end

  def disco_items(to) do
    iq(to, "get", xmlel(name: "query", attrs: [{"xmlns", ns_disco_items}]))
  end

  @doc """
  Generates a presence stanza to join a MUC room.

  ## Examples
      iex> Hedwig.Stanza.join("lobby@muc.localhost", "hedwigbot")
      {:xmlel, "presence", [{"to", "lobby@muc.localhost/hedwigbot"}],
       [{:xmlel, "x", [{"xmlns", "http://jabber.org/protocol/muc"}], []}]}
  """
  def join(room, username) do
    xmlel(name: "presence",
      attrs: [
        {"to", "#{room}/#{username}"}
      ],
      children: [
        xmlel(name: "x",
          attrs: [{"xmlns", ns_muc}],
          children: [
            xmlel(name: "history",
              attrs: [{"maxstanzas", "0"}])
          ])
      ])
  end

  def chat(to, body), do: message("chat", to, body)
  def normal(to, body), do: message("normal", to, body)
  def groupchat(to, body), do: message("groupchat", to, body)

  def message(type, to, message) do
    xmlel(name: "message",
      attrs: [
        {"to", to},
        {"type", type},
        {"id", id},
        {"xml:lang", "en"}
      ],
      children: generate_body(message))
  end

  def generate_body(data) do
    cond do
      is_list(data) ->
        data
      is_tuple(data) ->
        [data]
      true ->
        [body(data)]
    end
  end

  def body(data) do
    xmlel(name: "body",
      children: [
        :exml.escape_cdata(data)
      ])
  end

  def xhtml_im(data) when is_binary(data) do
    {:ok, data} = :exml.parse(data)
    xhtml_im(data)
  end
  def xhtml_im(data) do
    xmlel(name: "html",
      attrs: [
        {"xmlns", ns_xhtml_im}
      ],
      children: [
        xmlel(name: "body",
          attrs: [
            {"xmlns", ns_xhtml}
          ],
          children: [
            data
          ])
      ])
  end

  end

  def base64_cdata(payload) do
    [xmlcdata(content: Base.encode64(payload))]
  end

  @doc """
  Generates a random hex string for use as an id for a stanza.
  """
  def id do
    :crypto.rand_bytes(2) |> Base.encode16(case: :lower)
  end
end
