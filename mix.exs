defmodule Exlytics.MixProject do
  use Mix.Project

  def project do
    [
      app: :exlytics,
      version: "0.1.0",
      elixir: "~> 1.9",
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
      {:google_api_firestore, "~> 0.12"},
      {:goth, "~> 1.2.0"},
      {:plug_cowboy, "~> 2.1.1"},
      {:dialyxir, "~> 0.4", only: [:dev]},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
