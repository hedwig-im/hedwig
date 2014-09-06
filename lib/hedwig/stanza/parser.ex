defmodule Hedwig.Stanza.Parser do
  @moduledoc """
  Parses XML records into related structs.
  """
  require Logger

  use Hedwig.XML

  alias Hedwig.JID
  alias Hedwig.Stanzas.IQ
  alias Hedwig.Stanzas.Message
  alias Hedwig.Stanzas.Presence

  def parse(xmlel(name: "message") = stanza) do
    %Message{
      to:   to(stanza),
      from: from(stanza),
      type: type(stanza),
      body: body(stanza),
      html: html(stanza),
      delayed?: delayed?(stanza)}
  end

  def parse(xmlel(name: "presence") = stanza) do
    %Presence{
      to:   to(stanza),
      from: from(stanza),
      type: type(stanza, "available")
    }
  end

  def parse(xmlel(name: "iq") = stanza), do: %IQ{}

  def parse(stanza), do: stanza

  def to(stanza), do: XML.attr(stanza, "to") |> JID.parse
  def from(stanza), do: XML.attr(stanza, "from") |> JID.parse

  def type(stanza, default \\ nil), do: XML.attr(stanza, "type", default)

  def body(stanza), do: XML.subelement(stanza, "body") |> XML.cdata
  def html(stanza), do: XML.subelement(stanza, "html")

  def delayed?(xmlel(children: children)) do
    Enum.any? children, fn child ->
      elem(child, 1) == "delay" || elem(child, 1) == "x" && XML.attr(child, "xmlns") == "jabber:x:delay"
    end
  end
end

