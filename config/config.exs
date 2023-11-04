import Config

config :exlytics, cache: Exlytics.Cache.Redis
config :exlytics, host: "override", port: "override"
config :exlytics, redis: "redis://localhost:6379/0"
config :exlytics, storage: Exlytics.Storage.GoogleStorage, container: "bueckered-exlytics"
config :exlytics, time_adapter: Exlytics.Utils.TimeAdapter

import_config "#{Mix.env()}.exs"
