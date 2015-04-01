# Changelog

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
