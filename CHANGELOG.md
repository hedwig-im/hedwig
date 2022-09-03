# Changelog

## v1.0.1 (2018-01-26)

- Clean up warnings

## v1.0.0 (2016-11-20)

- Improvements
  - Handle disconnects with `handle_disconnect/2` in the robot module. See docs
    for details.
  - Responders are now `GenServer`s.

- Backwards Incompatible Changes
  - The `user` field on `Hedwig.Message` is now a `Hedwig.User` struct.
    This should aid in consistency across adapters.
  - `after_connect/1` is now `handle_connect/1`. See the docs for details.
  - Adapters should now call `Hedwig.Robot.handle_in/2` rather than `handle_message`
    for incoming messages. See the docs for details.
  - `Hedwig.Registry` has been removed. Alternatives are outlined in the README.
  - `GreatSuccess` and `ShipIt` responders have been moved in the `examples`
    directory and no longer shipped with Hedwig.

## v1.0.0-rc.4 (2016-04-17)

- Breaking Changes
  - The `Panzy` responder has been removed. You will need to remove it from your
    bot's list of responders (if you had previously had it configured).
  - The `adapter` field has been removed from the `Hedwig.Message` struct.
  - Robots are now a proper `GenServer`.

Diff: https://github.com/hedwig-im/hedwig/compare/v1.0.0-rc3...v1.0.0-rc.4

## v1.0.0-rc3 (2016-02-04)

Diff: https://github.com/hedwig-im/hedwig/compare/v1.0.0-rc2...v1.0.0-rc3

## v1.0.0-rc2 (2016-02-04)

Diff: https://github.com/hedwig-im/hedwig/compare/v1.0.0-rc1...v1.0.0-rc2

## v1.0.0-rc1 (2016-01-08)

Diff: https://github.com/hedwig-im/hedwig/compare/v1.0.0-rc0...v1.0.0-rc1

## v1.0.0-rc0 (2015-12-19)

Major rewrite and breaking changes. See the diff below for details.

Diff: https://github.com/hedwig-im/hedwig/compare/v0.3.0...v1.0.0-rc0

## v0.3.0 (2015-10-16)

- Improvements
  - Documentation Improvements
  - Added `Hedwig.Stanza.presence/2`
  - Increased timeout in `Hedwig.Conn` to `30_000` ms.

Diff: https://github.com/hedwig-im/hedwig/compare/v0.2.0...v0.3.0

## v0.2.0 (2015-08-09)

- Improvements

  - `Hedwig.whereis/1` can be used to return the `pid` of a client by the `jid`
  - Clients are now supervised via `:simple_one_for_one` and can be
    started/stopped via `Hedwig.start_client/1` and `Hedwig.stop_client/1`
  - Supports inband registration via `Stanza.set_inband_register/2`
  - Supports subscribing to a PubSub node via `Stanza.subscribe/3`

- Backwards Incompatible Changes

  - Clients are no longer configured via `config.exs`. Instead you must now manage
    starting/stopping clients via `Hedwig.start_client/1` and `Hedwig.stop_client/1`

Release Diff: https://github.com/scrogson/hedwig/compare/v0.1.0...v0.2.0

## v0.1.0 (2015-01-04)

- Bug Fixes
  - Default `type` for a `presence` stanza is now `nil`
  - Default `type` for a `message` stanza is now `normal`
  - Feature negotiation is now handled a second time if the connection is upgraded to TLS.

- Improvements

  - Authentication has been cleaned up and allows you to configure your preferred auth mechanism.
  - Support `ANONYMOUS` auth mechanism.
  - `Stanza.iq/{2,3}` - `iq` stanzas can now be sent to a specified `jid`.
  - `Stanza.get_roster/0` to fetch the client's roster.
  - `Stanza.get_vcard/1` to fetch the vcard of a specified `jid`.
  - `Stanza.disco_info/1` to discover features and capabilities of a server or client.
  - `Stanza.disco_items/1` to discover features and capabilities of a server or client.
  - `Stanza.presence/1` to allow a client to become `unavailable`.
  - `JID` now implements `String.Chars.to_string/1` protocol.
  - `ignore_from_self?` option to allow stanzas to be processed for messages sent by the client. Defaults to `false`.
  - Clients can now be stopped cleanly. Send a message of `{:stop, reason}` and the client will send an `unavailable` presence and close the stream.
  - Stanza parsing is now more robust. Parses into appropriate structs and includes a `payload` key for access to the `raw` parsed data structure.

Release Diff: https://github.com/scrogson/hedwig/compare/v0.0.3...v0.1.0
