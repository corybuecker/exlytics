import Config

config :exlytics, host: "localhost", port: "4000"

config :exlytics, Exlytics.Storage.Postgresql.Repo,
  url: System.get_env("DATABASE_CONNECTION_URL", "ecto://postgres@localhost:5432/exlytics_test"),
  # migration_default_prefix: "exlytics",
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox

config :exlytics, storage: Exlytics.Storage.Postgresql

config :goth,
  disabled: true
