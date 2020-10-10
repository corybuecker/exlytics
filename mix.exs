defmodule Exlytics.MixProject do
  use Mix.Project

  def project do
    [
      app: :exlytics,
      version: "1.0.0",
      elixir: ">= 1.10.4",
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
      {:plug_cowboy, "~> 2.3.0"},
      {:credo, "~> 1.4.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false},
      {:lettuce, "~> 0.1.0", only: [:dev]},
      {:ecto_sql, "~> 3.5.0"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.2.2"}
    ]
  end
end
