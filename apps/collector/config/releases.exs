import Config

config :collector, host: System.get_env("HOST"), port: System.get_env("PORT")
config :data, Exlytics.Data.Repo, url: System.get_env("DATABASE_CONNECTION")
