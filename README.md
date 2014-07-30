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
