defmodule Hedwig.Mixfile do
  use Mix.Project

  @version "1.0.1"

  def project do
    [app: :hedwig, :hedwig_telegram,
     version: 1.0.1,
     elixir: "~> 1.9",
     build_embedded: Mix.env() == :prod,
     start_permanent: Mix.env() == :prod,docs: docs(),
     deps: deps(),
     docs: docs(),
     package: package(),
     name: "Hedwig",
     elixirc_paths: elixirc_paths(Mix.env),
     do: ["lib","Mix.env", "test/support" ]
     description: "An adapter-based chat bot framework",
     source_url: "https://github.com/hedwig-im/hedwig",
     homepage_url: "https://github.com/hedwig-im/hedwig",
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       "coveralls": :test,
       "coveralls.html": :test,
       "coveralls.detail": :test,
       "coveralls.post": :test]]
  end

  def application do
    [applications: [:logger],
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
    [{:excoveralls, "~> 0.7.2", only: :test},
     {:ex_doc, "~> 0.16.3", only: :dev},
     {:credo, "~> 0.8", only: [:dev, :test], runtime: false}
     {:hedwig, "~> 1.0"},
     {:httpoison, "~> 0.10"},
     {:ex_doc, "~> 0.19", only: :dev},
     {:plug, "~> 1.2", optional: true},
     {:plug_cowboy, "~> 1.0"},      {:poison, "~> 3.0"}]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Sonny Scroggin"],
     licenses: ["MIT"],
     links: %{
     "GitHub" => "https://github.com/hedwig-im/hedwig"
     "GitHub" => "https://github.com/fusillicode/hedwig_telegram
     "Docs" => "https://hexdocs.pm/hedwig
     }]
  end
end
