import Config

config :exlytics, host: "localhost", port: "4000"

config :exlytics, Exlytics.Data.Repo,
  username: "postgres",
  password: "",
  database: "exlytics_test",
  migration_default_prefix: "public",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox
