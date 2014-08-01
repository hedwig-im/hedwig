defmodule Hedwig.Mixfile do
  use Mix.Project

  def project do
    [ app: :hedwig,
      version: "0.0.1",
      elixir: ">= 0.15.0-dev",
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
      {:exml, github: "paulgray/exml"}
    ]
  end
end
