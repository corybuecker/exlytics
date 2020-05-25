import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :logger, level: :info

config :data, Exlytics.Data.Repo, url: System.get_env("DATABASE_CONNECTION")

config :dashboard, Exlytics.DashboardWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base,
  url: [host: System.get_env("HOST"), port: 80],
  cache_static_manifest: "priv/static/js/manifest.json",
  server: true
