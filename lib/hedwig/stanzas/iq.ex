defmodule Hedwig.Stanzas.IQ do
  use Hedwig.XML

  alias Hedwig.JID

  @type jid :: JID.t

  @type t :: %__MODULE__{
    id: binary,
    to: jid,
    from: jid,
    type: binary,
    payload: list,
    client: pid,
    matches: nil
  }

  defstruct [
    id:       nil,
    to:       nil,
    from:     nil,
    type:     nil,
    payload: [],
    client:   nil,
    matches:  nil
  ]
end
