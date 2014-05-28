defmodule Hedwig.XML do
  @moduledoc """
  Provides records for exml library.
  """
  defmacro __using__(_opts) do
    quote do
      use Hedwig.XMLNS
      require Record
      import unquote __MODULE__

      Record.defrecordp :xmlel, name: "", attrs: [], children: []
      Record.defrecordp :xmlcdata, content: []
      Record.defrecordp :xmlstreamstart, name: "", attrs: []
      Record.defrecordp :xmlstreamend, name: ""
    end
  end
end
