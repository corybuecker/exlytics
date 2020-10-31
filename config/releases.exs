import Config

config :exlytics, host: System.get_env("HOST"), port: System.get_env("PORT")

config :exlytics, Exlytics.Data.Repo,
  socket: System.get_env("DATABASE_CONNECTION"),
  migration_default_prefix: "exlytics"
