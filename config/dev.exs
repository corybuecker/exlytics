import Config

config :exlytics,
  host: "localhost",
  port: "8080"

config :exlytics, Exlytics.Data.Repo,
  username: "postgres",
  database: "exlytics",
  migration_default_prefix: "exlytics",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
