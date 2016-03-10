
defmodule Hedwig.Brain do

  @doc "memorize something"
  @callback memorize(String.t, any) :: any

  @doc "remember something"
  @callback remember(String.t) :: any

  @doc "forget"
  @callback forget(String.t) :: any
end
