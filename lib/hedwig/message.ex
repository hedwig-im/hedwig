defmodule Hedwig.Message do
  @moduledoc """
  Hedwig Message
  """

  @type adapter :: {module, term}
  @type matches :: List.t | Map.t
  @type ref     :: reference
  @type robot   :: Hedwig.Robot.t
  @type room    :: binary
  @type text    :: binary
  @type type    :: binary
  @type user    :: binary

  @type t :: %__MODULE__{
    adapter: adapter,
    matches: matches,
    ref:     ref,
    robot:   robot,
    room:    room,
    text:    text,
    type:    type,
    user:    user
  }

  defstruct adapter: nil,
            matches: nil,
            ref:     nil,
            robot:   nil,
            room:    nil,
            text:    nil,
            type:    nil,
            user:    nil
end
