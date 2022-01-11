import Config

config :exlytics, Scheduler,
  jobs: [
    {"* * * * *", {Exlytics.Storage.GoogleStorage.Loader, :load, []}}
  ]

config :exlytics, storage: Exlytics.Storage.Postgresql
