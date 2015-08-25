defmodule Hedwig.Mixfile do
  use Mix.Project

  def project do
    [app: :hedwig,
     version: "0.1.0",
     elixir: "~> 1.0",
     deps: deps,
     package: package,
     name: "Hedwig",
     description: "XMPP Client/Bot Framework",
     source_url: "https://github.com/scrogson/hedwig",
     homepage_url: "https://github.com/scrogson/hedwig"]
  end

  def application do
    [applications: [:crypto, :ssl, :exml, :logger],
     mod: {Hedwig, []}]
  end

  defp deps do
    [{:exml, github: "paulgray/exml"},

     # Test dependencies
     {:ejabberd, github: "processone/ejabberd", tag: "15.07", only: :test},

     # Docs dependencies
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.8", only: :dev}]
  end

  defp package do
    [files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     contributors: ["Sonny Scroggin"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/scrogson/hedwig",
       "Docs" => "https://hexdocs.pm/hedwig"
     }]
  end
end
