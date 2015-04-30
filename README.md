# Hedwig

> XMPP Client/Bot Framework for Elixir

[![Build Status](https://travis-ci.org/scrogson/hedwig.svg?branch=master)](https://travis-ci.org/scrogson/hedwig)

![Hedwig](https://raw.githubusercontent.com/scrogson/hedwig/master/hedwig.png)

## Usage

Add the dependencies to you `mix.exs` file.

```elixir
defp deps do
  [{:hedwig, "~> 0.1.0"},
   {:exml, github: "paulgray/exml"}]
end
```

Update your applications to include both projects.

```elixir
def applications do
  [applications: [:hedwig, :exml]]
end
```

Configure multiple clients/bots to connect to an XMPP server. Specify handlers for incoming `message`, `presence`, or `iq` stanzas.

## Config

```elixir
use Mix.Config

alias Hedwig.Handlers

config :hedwig,
  clients: [
    %{
      jid: "romeo@capulet.lit",
      password: "iL0v3JuL13t"
      nickname: "loverboy",
      resource: "chamber",
      config: %{ # This is only necessary if you need to override the defaults.
        server: "im.capulet.lit",
        port: 9222, # Default port is 5222
        require_tls?: true,
        use_compression?: false,
        use_stream_management?: false,
        transport: :tcp
      },
      rooms: [
        "lobby@conference.capulet.lit"
      ],
      handlers: [
        {Handlers.Echo, %{}}
      ]
    },
    %{
      jid: "juliet@capulet.lit",
      password: "R0m30!"
      nickname: "romeosgirl",
      resource: "balcony",
      rooms: [
        "lobby@conference.capulet.lit"
      ],
      handlers: [
        {Handlers.Help, %{}},
        {Handlers.GreatSuccess, %{}}
      ]
    }
  ]
```

## Handler Example

```elixir
defmodule Hedwig.Handlers.GreatSuccess do
  @moduledoc """
  Borat, Great Success!

  Replies with a random link to a Borat image when a message contains
  'great success'.
  """

  @usage """
  <text> (great success) - Replies with a random link to a Borat image.
  """

  use Hedwig.Handler

  @links [
    "http://mjanja.co.ke/wordpress/wp-content/uploads/2013/09/borat_great_success.jpg",
    "http://s2.quickmeme.com/img/13/1324dfd733535e58dba70264e6d05c9b70346204d2cacef65abef9c702746d1c.jpg",
    "https://www.youtube.com/watch?v=r13riaRKGo0"
  ]

  def handle_event(%Message{} = msg, opts) do
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
```

## License

The MIT License (MIT)

Copyright (c) 2015 Sonny Scroggin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
