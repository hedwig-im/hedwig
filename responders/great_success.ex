defmodule Hedwig.Responders.GreatSuccess do
  @moduledoc """
  Borat, Great Success!

  Replies with a random link to a Borat image when a message contains
  'great success'.
  """

  use Hedwig.Responder

  @links [
    "http://mjanja.co.ke/wordpress/wp-content/uploads/2013/09/borat_great_success.jpg",
    "http://s2.quickmeme.com/img/13/1324dfd733535e58dba70264e6d05c9b70346204d2cacef65abef9c702746d1c.jpg",
    "https://www.youtube.com/watch?v=r13riaRKGo0"
  ]

  @usage """
  great success - Displays a random Borat image.
  """
  hear ~r/great success(!)?/i, msg do
    reply msg, random(@links)
  end
end
