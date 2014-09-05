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
      to:   XML.attr(stanza, "to")   |> JID.parse,
      from: XML.attr(stanza, "from") |> JID.parse,
      type: XML.attr(stanza, "type"),
      body: XML.subelement(stanza, "body") |> XML.cdata,
      html: XML.subelement(stanza, "html"),
      delayed?: delayed?(stanza)}
  end

  def parse(xmlel(name: "presence") = stanza) do
    %Presence{
      to:   XML.attr(stanza, "to")   |> JID.parse,
      from: XML.attr(stanza, "from") |> JID.parse,
      type: XML.attr(stanza, "type") || "available"
    }
  end

  def parse(xmlel(name: "iq") = stanza), do: %IQ{}

  def parse(stanza), do: stanza

  def delayed?(xmlel(children: children)) do
    Enum.any? children, fn child ->
      elem(child, 1) == "delay"
    end
  end
end

