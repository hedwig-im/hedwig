defmodule Hedwig.XML do
  @moduledoc """
  Provides records for exml library.
  """
  defmacro __using__(_opts) do
    quote do
      use Hedwig.XMLNS
      import unquote __MODULE__

      defrecordp :xmlel, name: "", attrs: [], children: []
      defrecordp :xmlcdata, content: []
      defrecordp :xmlstreamstart, name: "", attrs: []
      defrecordp :xmlstreamend, name: ""
    end
  end
end
