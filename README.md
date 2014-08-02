# Hedwig

> XMPP Client/Bot Framework for Elixir

![Hedwig](https://raw.githubusercontent.com/scrogson/hedwig/master/hedwig.png)

This is very much a work in progress as I learn Erlang/Elixir and OTP
principles.

## Usage

I'm still working out all the details. Ultimately you will be able to configure multiple clients/bots to connect to an XMPP server and specify handlers for incoming `message` or `presence` notifications.

Example config:

```elixir
use Mix.Config

config :hedwig,
  clients: [
    %{
      jid: "romeo@capulet.lit",
      password: "iL0v3JuL13t"
      nickname: "loverboy",
      resource: "chamber",
      config: [ # This is only necessary if you need to override the defaults.
        server: "im.capulet.lit",
        port: 9222, # Default port is 5222
        require_tls?: true,
        use_compression?: false,
        use_stream_management?: false,
        transport: :tcp
      ],
      rooms: [
        "lobby@conference.capulet.lit"
      ],
      scripts: [
        canned_replies: [],
        hangout: [
          hangout_url: System.get_env("HANGOUT_URL")
        ]
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
      scripts: [
        canned_replies: [],
        hangout: [
          hangout_url: System.get_env("HANGOUT_URL")
        ]
      ]
    }
  ]
```

## License

The MIT License (MIT)

Copyright (c) 2014 Sonny Scroggin

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
