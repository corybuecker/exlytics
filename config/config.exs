import Config

config :exlytics,
  host: System.get_env("HOST"),
  port: System.get_env("PORT"),
  ecto_repos: [Exlytics.Data.Repo]

config :exlytics, Exlytics.Data.Repo, url: System.get_env("DATABASE_CONNECTION")
import_config "#{Mix.env()}.exs"