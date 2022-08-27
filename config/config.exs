import Config

config :exlytics, host: "override", port: "override"

config :exlytics, storage: Exlytics.Storage.GoogleStorage, container: "bueckered-exlytics"
config :exlytics, time_adapter: Exlytics.Utils.TimeAdapter

import_config "#{Mix.env()}.exs"
