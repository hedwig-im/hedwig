defmodule Hedwig.Mixfile do
  use Mix.Project

  def project do
    [ app: :hedwig,
      version: "0.0.1",
      elixir: "~> 0.13.0-dev",
      deps: deps ]
  end

  def application do
    []
  end

  defp deps do
    []
  end
end
