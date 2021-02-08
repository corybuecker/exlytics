import Config

config :exlytics, host: System.get_env("HOST"), port: System.get_env("PORT")

config :exlytics, Exlytics.Data.Repo,
  username: "exlytics",
  password: "exlytics",
  database: "exlytics",
  migration_default_prefix: "exlytics"