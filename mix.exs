defmodule Exlytics.MixProject do
  use Mix.Project

  def project do
    [
      app: :exlytics,
      version: "1.0.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Exlytics, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mongodb, "~> 0.5.1"},
      {:plug_cowboy, "~> 2.1.2"},
      {:poolboy, ">= 0.0.0"},
      {:credo, "~> 1.3.1", only: [:dev, :integration], runtime: false},
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false},
      {:lettuce, "~> 0.1.0", only: [:dev]}
    ]
  end
end
