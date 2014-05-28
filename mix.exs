defmodule Hedwig.Mixfile do
  use Mix.Project

  def project do
    [ app: :hedwig,
      version: "0.0.1",
      elixir: "0.13.3",
      deps: deps ]
  end

  def application do
    [
      applications: [:crypto, :ssl, :exml],
      mod: { Hedwig, [] }
    ]
  end

  defp deps do
    [
      {:exml, github: "paulgray/exml"},
      {:socket, github: "meh/elixir-socket"}
    ]
  end
end
