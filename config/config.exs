import Config

config :exlytics, host: "override", port: "override"

config :exlytics, ecto_repos: [Exlytics.Storage.Postgresql.Repo]
config :exlytics, Exlytics.Storage.Postgresql.Repo, pool_size: 3
config :exlytics, storage: Exlytics.Storage.GoogleStorage
config :exlytics, time_adapter: Exlytics.Utils.TimeAdapter

import_config "#{Mix.env()}.exs"
