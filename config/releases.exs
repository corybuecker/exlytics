import Config

config :exlytics, host: System.get_env("HOST"), port: System.get_env("PORT")

config :exlytics, Exlytics.Storage.Postgresql.Repo, url: System.get_env("DATABASE_URL")
# migration_default_prefix: "exlytics"
