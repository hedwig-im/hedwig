defmodule Hedwig.Stanza.Parser do
  @moduledoc """
  Parses XML records into related structs.
  """
  use Hedwig.XML
  alias Hedwig.JID

  def parse(xmlel(name: "message", attrs: attrs, children: children) = stanza) do
    struct(Message, parse_attrs(attrs))
    |> struct([body: get_body(stanza)])
    |> struct([html: get_html(stanza)])
    |> struct([payload: parse_payload(children)])
    |> struct([delayed?: delayed?(stanza)])
  end

  def parse(xmlel(name: "presence", attrs: attrs, children: children) = stanza) do
    struct(Presence, parse_attrs(attrs))
    |> struct([show: get_show(stanza)])
    |> struct([status: get_status(stanza)])
    |> struct([payload: parse_payload(children)])
  end

  def parse(xmlel(name: "iq", attrs: attrs, children: children) = stanza) do
    struct(IQ, parse_attrs(attrs))
    |> struct([payload: parse_payload(children)])
  end

  def parse(xmlel(name: name, attrs: attrs, children: payload)) do
    [name: name]
    |> Dict.merge(parse_attrs(attrs))
    |> Dict.merge([payload: parse_payload(payload)])
    |> Enum.into(%{})
  end

  def parse(xmlcdata(content: content)), do: content

  def parse(stanza), do: stanza

  defp parse_attrs([]), do: []
  defp parse_attrs(attrs) do
    parse_attrs(attrs, [])
  end
  defp parse_attrs([{k,v}|rest], acc) do
    parse_attrs(rest, [parse_attr({k,v})|acc])
  end
  defp parse_attrs([], acc), do: acc

  defp parse_attr({key, value}) when key in ["to", "from", "jid"] do
    {String.to_atom(key), JID.parse(value)}
  end
  defp parse_attr({key, value}) do
    {String.to_atom(key), value}
  end

  defp parse_payload([]), do: []
  defp parse_payload(payload) when is_list(payload) do
    Enum.reduce payload, [], &parse_payload(&1, &2)
  end
  defp parse_payload([], acc), do: acc
  defp parse_payload(payload, acc), do: [parse(payload)|acc]


  defp get_body(stanza), do: subelement(stanza, "body") |> cdata
  defp get_html(stanza), do: subelement(stanza, "html")

  defp get_show(stanza), do: subelement(stanza, "show") |> cdata
  defp get_status(stanza), do: subelement(stanza, "status") |> cdata

  defp delayed?(xmlel(children: children)) do
    Enum.any? children, fn child ->
      elem(child, 1) == "delay" || elem(child, 1) == "x" && XML.attr(child, "xmlns") == "jabber:x:delay"
    end
  end
end

