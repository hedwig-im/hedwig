defmodule Hedwig.Mixfile do
  use Mix.Project

  @version "1.0.0-rc.4"

  def project do
    [app: :hedwig,
     version: @version,
     elixir: "~> 1.2",
     docs: docs(),
     deps: deps(),
     package: package(),
     name: "Hedwig",
     elixirc_paths: elixirc_paths(Mix.env),
     description: "An adapter-based chat bot framework",
     source_url: "https://github.com/hedwig-im/hedwig",
     homepage_url: "https://github.com/hedwig-im/hedwig",
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       "coveralls": :test,
       "coveralls.detail": :test,
       "coveralls.post": :test,
       "docs": :docs]]
  end

  def application do
    [applications: [:crypto, :ssl, :logger, :gproc],
     mod: {Hedwig, []}]
  end

  defp docs do
    [extras: docs_extras(),
      main: "readme"]
  end

  defp docs_extras do
    ["README.md"]
  end

  defp deps do
    [{:gproc, "~> 0.5"},

     # Test dependencies
     {:excoveralls, "~> 0.5", only: :test},

     # Documentation dependencies
     {:earmark, "~> 0.2", only: :docs},
     {:ex_doc, "~> 0.11", only: :docs}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib", "responders"]

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
