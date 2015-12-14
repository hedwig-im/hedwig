defmodule Hedwig.Mixfile do
  use Mix.Project

  def project do
    [app: :hedwig,
     version: "0.4.0",
     elixir: "~> 1.0 or ~> 1.1",
     deps: deps,
     package: package,
     name: "Hedwig",
     description: "An adapter-based chat bot framework",
     source_url: "https://github.com/hedwig-im/hedwig",
     homepage_url: "https://github.com/hedwig-im/hedwig",
     test_coverage: [tool: ExCoveralls]]
  end

  def application do
    [applications: [:crypto, :ssl, :logger, :gproc],
     mod: {Hedwig, []}]
  end

  defp deps do
    [{:gproc, "~> 0.5"},

     # Test dependencies
     {:excoveralls, "~> 0.3", only: :test},

     # Dev dependencies
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.10", only: :dev}]
  end

  defp package do
    [files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     maintainers: ["Sonny Scroggin"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/hedwig-im/hedwig",
       "Docs" => "https://hexdocs.pm/hedwig"
     }]
  end
end
