import Config

config :exlytics, host: "localhost", port: "4000"

config :exlytics, Exlytics.Data.Repo,
  username: "exlytics",
  password: "exlytics",
  database: "exlytics_test",
  migration_default_prefix: "exlytics",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox
