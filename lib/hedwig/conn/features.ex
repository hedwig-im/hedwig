defmodule Hedwig.Conn.Features do
  @moduledoc """
  A struct to hold the connection stream features.
  """

  @type t :: %__MODULE__{}
  defstruct tls?:               false,
            compression?:       false,
            stream_management?: false,
            mechanisms:         []
end
