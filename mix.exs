defmodule Hedwig.Mixfile do
  use Mix.Project

  @description """
  XMPP Client/Bot Framework
  """

  def project do
    [
      app: :hedwig,
      version: "0.1.0",
      elixir: "~> 1.0",
      deps: deps,
      description: @description,
      package: package
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

  defp package do
    [
      files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      contributors: ["Sonny Scroggin"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/scrogson/hedwig"}
    ]
  end
end
