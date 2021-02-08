import Config

config :exlytics, host: "override", port: "override"

config :exlytics, ecto_repos: [Exlytics.Data.Repo]
config :exlytics, Exlytics.Data.Repo, pool_size: 3

import_config "#{Mix.env()}.exs"
