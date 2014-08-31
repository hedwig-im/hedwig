defmodule Hedwig.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hedwig,
      version: "0.0.1",
      elixir: "~> 1.0.0-rc2",
      deps: deps
    ]
  end

  def application do
    [
      applications: [:crypto, :ssl, :exml, :logger],
      mod: {Hedwig, []}
    ]
  end

  defp deps do
    [
      {:exml, github: "paulgray/exml"}
    ]
  end
end
