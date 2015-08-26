# Hedwig

> XMPP Client/Bot Framework for Elixir

[![Build Status](https://travis-ci.org/scrogson/hedwig.svg?branch=master)](https://travis-ci.org/scrogson/hedwig)
[![Coverage Status](https://coveralls.io/repos/scrogson/hedwig/badge.svg?branch=master&service=github)](https://coveralls.io/github/scrogson/hedwig?branch=master)

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

## Configuring Clients

```elixir
romeo = %{
  jid: "romeo@capulet.lit",
  password: "iL0v3JuL13t",
  nickname: "loverboy",
  resource: "chamber",
  rooms: ["lobby@conference.capulet.lit"],
  handlers: [{Hedwig.Handlers.Panzy, %{}}]
}

# Start a client for Romeo. This client will be supervised
# and restarted if it crashes abnormally.
{:ok, pid} = Hedwig.start_client(romeo)

# Get the pid of the client by the JID
pid = Hedwig.whereis("romeo@capulet.lit")

# Stop the client.
Hedwig.stop_client(pid)
```

## Setting a client's server configuration

If you need to override the default server configuration, you can add the
`:config` key to the client map:

```elixir
config: %{
  server: "im.capulet.lit", # default: inferred by the JID
  port: 9222, # default: 5222
  require_tls?: true, # default: false
  ignore_from_self?: false, # defaults to true
},
```

## Building Handlers

Handlers are `GenEvent` handlers that will process incoming stanzas.

All that's needed is to `use Hedwig.Handler` and define `handle_event/2`
functions to process incoming `Message`, `Presence`, or `IQ` stanzas.

Here is an example:

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

## NOTE: Always create a default handle_event function

If you do not create a default `handle_event/2` function, your event handler
will surely crash. So be sure to add a default at the bottom.

```elixir
def handle_event(_, opts), do: {:ok, opts}
```

## @usage

The `@usage` module attribute works nicely with `Hedwig.Handlers.Help`. If you
install the help handler, your bot will listen for `<your-bots-nickname> help`
and respond with a message containing all of the installed handlers `@usage`
text.

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
