import Config

config :exlytics, host: "localhost", port: "4000"
config :exlytics, time_adapter: Exlytics.Utils.FakeTimeAdapter
config :exlytics, storage: Exlytics.Utils.FakeGoogleStorage, container: "test"

config :goth, disabled: true
