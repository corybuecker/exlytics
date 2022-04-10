defmodule Exlytics.MixProject do
  use Mix.Project

  def project do
    [
      app: :exlytics,
      version: "1.0.0",
      elixir: "1.13.4",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {Exlytics, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:certifi, "~> 2.9"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:ecto_sql, "~> 3.7"},
      {:google_api_storage, "~> 0.33"},
      {:goth, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:uuid, "~> 1.1"}
    ]
  end
end
