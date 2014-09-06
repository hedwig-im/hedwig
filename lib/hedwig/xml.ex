defmodule Hedwig.XML do
  @moduledoc """
  Provides functions and records for exml library.
  """
  defmacro __using__(_opts) do
    quote do
      use Hedwig.XMLNS
      require Record
      import unquote __MODULE__
      alias unquote __MODULE__
      alias Hedwig.Stanza

      Record.defrecordp :xmlel, name: "", attrs: [], children: []
      Record.defrecordp :xmlcdata, content: []
      Record.defrecordp :xmlstreamstart, name: "", attrs: []
      Record.defrecordp :xmlstreamend, name: ""
    end
  end

  @doc """
  Returns the given attribute value or default.
  """
  def attr(element, name, default \\ nil) do
    :exml_query.attr(element, name, default)
  end

  def subelement(element, name, default \\ nil) do
    :exml_query.subelement(element, name, default)
  end

  def cdata(nil), do: ""
  def cdata(element), do: :exml_query.cdata(element)
end
