defmodule Hedwig.Stanza.ParserTest do
  use ExUnit.Case, async: true

  use Hedwig.XML

  alias Hedwig.Stanza.Parser

  @iq {:xmlel, "iq", [{"from", "im.test.dev"}, {"to", "scrogson@im.test.dev/issues"}, {"id", "b0e3"}, {"type", "result"}],
        [
          {:xmlel, "query", [{"xmlns", "http://jabber.org/protocol/disco#items"}],
            [
              {:xmlel, "item", [{"jid", "conference.im.test.dev"}], []},
              {:xmlel, "item", [{"jid", "pubsub.im.test.dev"}], []}
            ]
          }
        ]
      }

  test "it parses stanzas" do
    parsed = Parser.parse(@iq)
    assert parsed.type == "result"
    assert parsed.id == "b0e3"
    assert parsed.to == %Hedwig.JID{user: "scrogson", server: "im.test.dev", resource: "issues"}
    assert parsed.from == %Hedwig.JID{user: "", server: "im.test.dev", resource: ""}
    assert parsed.payload [%{name: "query"}]
  end
end
