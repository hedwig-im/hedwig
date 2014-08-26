defmodule Hedwig.Stanzas.Message do
  use Hedwig.XML

  alias Hedwig.JID

  @type jid :: JID.t

  @type t :: %__MODULE__{
    client: pid,
    from: jid,
    to: jid,
    body: binary | list,
    html: binary | list | nil,
    type: binary,
    delayed?: boolean}

  defstruct [
    client: nil,
    from: nil,
    to: nil,
    body: "",
    html: nil,
    type: "groupchat",
    delayed?: false]
end
