defmodule Hedwig.Handlers.GreatSuccess do
  @moduledoc """
  Borat, Great Success!
  """

  use Hedwig.Handler

  @links [
    "http://mjanja.co.ke/wordpress/wp-content/uploads/2013/09/borat_great_success.jpg",
    "http://s2.quickmeme.com/img/13/1324dfd733535e58dba70264e6d05c9b70346204d2cacef65abef9c702746d1c.jpg",
    "https://www.youtube.com/watch?v=r13riaRKGo0"
  ]

  def handle_event(%Message{delayed?: false} = msg, opts) do
    cond do
      hear ~r/great success(!)?/i, msg -> process msg
      true -> :ok
    end
    {:ok, opts}
  end
  def handle_event(_, opts), do: {:ok, opts}

  defp process(msg) do
    :random.seed(:os.timestamp)
    link = Enum.shuffle(@links) |> List.first
    reply(msg, Stanza.body(link))
  end
end
