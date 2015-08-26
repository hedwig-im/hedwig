defmodule Hedwig.RegistryTest do
  use ExUnit.Case

  @jid "bob@localhost"

  test "register/whereis" do
    assert :undefined = Hedwig.Registry.whereis(@jid)
    true = Hedwig.Registry.register(@jid)
    pid = Hedwig.Registry.whereis(@jid)
    assert pid == self()
  end
end

