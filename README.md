# Hedwig

> An Adapter-based Bot Framework for Elixir Applications

[![Build Status](https://travis-ci.org/hedwig-im/hedwig.svg?branch=master)](https://travis-ci.org/hedwig-im/hedwig)
[![Coverage Status](https://coveralls.io/repos/hedwig-im/hedwig/badge.svg?branch=master&service=github)](https://coveralls.io/github/hedwig-im/hedwig?branch=master)

![Hedwig](https://raw.githubusercontent.com/hedwig-im/hedwig/master/hedwig.png)

Hedwig is a chat bot, highly inspired by GitHub's [Hubot](https://hubot.github.com/).

Hedwig was designed for 2 use-cases:

  1. A single, stand-alone OTP application.
  2. Included as a dependency of other OTP applications.

You can spawn multiple bots at run-time with different configurations.

## Adapters

- [XMPP](https://github.com/hedwig-im/hedwig_xmpp)
- [Slack](https://github.com/hedwig-im/hedwig_slack)

## Usage

Hedwig ships with a console adapter to get you up and running quickly. It's
great for testing how your bot will respond to the messages it receives.

To add Hedwig to an existing Elixir application, add `:hedwig` to your list of
dependencies in your `mix.exs` file:

```elixir
defp deps do
  [{:hedwig, "~> 0.4.0"}]
end
```

Update your applications list to include `:hedwig`. This will ensure that the
Hedwig application, along with it's supervision tree is started when you start
your application.

```elixir
def applications do
  [applications: [:hedwig]]
end
```

## Create a robot module

Run the following mix task to generate a robot module in you application:

```
mix hedwig.gen.robot
```

This will create a file in `lib/my_app/robot.ex`.

```elixir
defmodule MyApp.Robot do
  use Hedwig.Robot, otp_app: :my_app
end
```

## Configure the module

This is mainly to setup the module to be compiled along with the adapter. An
adapter can inject functionality into your module if needed.

```elixir
# config/config.exs

config :my_app, MyApp.Robot,
  adapter: Hedwig.Adapters.Console,
  name: "hedwig",
  aka: "/",
  responders: [
    {Hedwig.Handlers.Help, []},
    {Hedwig.Handlers.Panzy, []}
  ]
```

### Start a bot.

You can start your bot as part of your application's supervision tree or by
using the supervision tree provided by Hedwig.

### Starting as part of your supervision tree:

```elixir
# add this to the list of your supervisor's children
worker(MyApp.Robot, [])
```

### Trying out the console adapter:

```
mix run --no-halt

Hedwig Console - press Ctrl+C to exit.

The console adapter is useful for quickly verifying how your
bot will respond based on the current installed responders.

scrogson> alfred help
alfred> alfred help <query> - Displays all help commands that match <query>.
alfred help - Displays all of the help commands that alfred knows about.
alfred: hey - Replies with 'sup?'
(tired|too? hard|upset|bored) - Replies with 'Panzy!'
great success - Displays a random Borat image.
ship it - Display a motivation squirrel
scrogson>
```

### Starting bots manually:

```elixir
# Start the bot via the module. The configuration options will be read in from
# config.exs
{:ok, pid} = Hedwig.start_robot(MyApp.Robot)

# You can also pass in a list of options that will override the configuration
# provided in config.exs (except for the adapter as that is compiled into the
# module).
{:ok, pid} = Hedwig.start_robot(MyApp.Robot, [name: "jeeves"])

# Get the pid of the robot by name
pid = Hedwig.whereis("hedwig")
# Stop the robot.
Hedwig.stop_robot(pid)

pid = Hedwig.whereis("jeeves")
Hedwig.stop_robot(pid)
```

## Building Responders

Responders are functions that will process incoming messages.

All that's needed is to `use Hedwig.Responder` and use the `hear/2`, or
`respond/2` macros to define a pattern to listen for and how to respond in
the block when a message matches.

Here is an example:

```elixir
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
  <text> (great success) - Replies with a random Borat image.
  """
  hear ~r/great success(!)?/i, msg do
    reply msg, random(@links)
  end
end
```

## @usage

The `@usage` module attribute works nicely with `Hedwig.Responders.Help`. If you
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
