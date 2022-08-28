import Config

config :exlytics, cache: Exlytics.Utils.FakeCache
config :exlytics, host: "localhost", port: "4000"
config :exlytics, storage: Exlytics.Utils.FakeGoogleStorage, container: "test"
config :exlytics, time_adapter: Exlytics.Utils.FakeTimeAdapter

config :goth, disabled: true
