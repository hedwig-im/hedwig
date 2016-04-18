defmodule Hedwig.User do
  @moduledoc ~S"""
  Module defining a `User` struct for `Hedwig.Message`.
  """

  @type t :: %__MODULE__{
    id: binary,
    name: binary
  }

  defstruct id: nil,
            name: nil
end
