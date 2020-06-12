defmodule Exlytics.Collector.MixProject do
  use Mix.Project

  def project do
    [
      app: :collector,
      version: "1.0.0",
      elixir: "1.10.3",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Exlytics.Collector, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:data, path: "../data"},
      {:plug_cowboy, "~> 2.3.0"},
      {:credo, "~> 1.4.0", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false},
      {:lettuce, "~> 0.1.0", only: [:dev]}
    ]
  end
end
