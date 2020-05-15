import Config

config :data, ecto_repos: [Exlytics.Data.Repo]
config :data, Exlytics.Data.Repo, url: System.get_env("DATABASE_CONNECTION")

import_config "#{Mix.env()}.exs"
