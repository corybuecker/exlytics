import Config

config :exlytics, Scheduler,
  jobs: [
    {"*/30 * * * *", {Exlytics.Storage.GoogleStorage.Loader, :load, []}}
  ]

config :exlytics, storage: Exlytics.Storage.GoogleStorage, container: "bueckered-exlytics-storage"
