defmodule Hedwig.Stanzas.Message do
  use Hedwig.XML

  alias Hedwig.JID

  @type jid :: JID.t

  @type t :: %__MODULE__{
    id: binary,
    to: jid,
    from: jid,
    type: binary,
    body: binary | list,
    html: binary | list | nil,
    payload: list,
    delayed?: boolean,
    client: pid,
    matches: list | %{} | nil
  }

  defstruct [
    id: "",
    to: nil,
    from: nil,
    type: "normal",
    body: "",
    html: nil,
    payload: [],
    delayed?: false,
    client: nil,
    matches: nil
  ]
end
