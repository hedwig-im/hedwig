defmodule Hedwig.Mixfile do
  use Mix.Project

  @version "1.0.0-rc0"

  def project do
    [app: :hedwig,
     version: @version,
     elixir: "~> 1.0 or ~> 1.2",
     deps: deps,
     package: package,
     name: "Hedwig",
     elixirc_paths: elixirc_paths(Mix.env),
     description: "An adapter-based chat bot framework",
     source_url: "https://github.com/hedwig-im/hedwig",
     homepage_url: "https://github.com/hedwig-im/hedwig",
     test_coverage: [tool: ExCoveralls]]
  end

  def application do
    [applications: [:crypto, :ssl, :logger, :gproc],
     mod: {Hedwig, []}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib", "responders"]

  defp deps do
    [{:gproc, "~> 0.5"},

     # Test dependencies
     {:excoveralls, "~> 0.3", only: :test},

     # Dev dependencies
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.10", only: :dev}]
  end

  defp package do
    [files: ["lib", "responders", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     maintainers: ["Sonny Scroggin"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/hedwig-im/hedwig",
       "Docs" => "https://hexdocs.pm/hedwig"
     }]
  end
end
