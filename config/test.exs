import Config

config :exlytics, host: "localhost", port: "4000"

config :exlytics, Exlytics.Data.Repo,
  url: System.get_env("DATABASE_CONNECTION_URL", "ecto://postgres@localhost:5432/exytics_test"),
  pool: Ecto.Adapters.SQL.Sandbox
