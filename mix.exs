defmodule Exlytics.MixProject do
  use Mix.Project

  def project do
    [
      app: :exlytics,
      version: "1.0.2",
      elixir: "1.15.4",
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
      {:castore, ">= 0.0.0"},
      {:certifi, "~> 2.12"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:google_api_storage, "~> 0.34"},
      {:goth, "~> 1.4"},
      {:plug_cowboy, "~> 2.5"},
      {:redix, "~> 1.1"},
      {:uuid, "~> 1.1"}
    ]
  end
end
