defmodule Hedwig.Conn.Features do
  @moduledoc """
  Parses XMPP Stream features.
  """

  use Hedwig.XML

  @type t :: %__MODULE__{}
  defstruct [
    tls?: false,
    compression?: false,
    stream_management?: false,
    mechanisms: []
  ]

  def parse_stream_features(features) do
    %__MODULE__{
      compression?: supports?(features, "compression"),
      tls?: supports?(features, "starttls"),
      stream_management?: supports?(features, "sm")
    }
  end

  def supported_auth_mechanisms(features) do
    case :exml_query.subelement(features, "mechanisms") do
      xml when Record.is_record(xml, :xmlel) ->
        mechanisms = xmlel(xml, :children)
        for mechanism <- mechanisms, into: [], do: :exml_query.cdata(mechanism)
      [] -> []
    end
  end

  def supports?(features, "compression") do
    case :exml_query.subelement(features, "compression") do
      xml when Record.is_record(xml, :xmlel) ->
        methods = xmlel(xml, :children)
        for method <- methods, into: [], do: :exml_query.cdata(method)
      _ -> false
    end
  end
  def supports?(features, feature) do
    case :exml_query.subelement(features, feature) do
      :undefined -> false
      _          -> true
    end
  end
end
