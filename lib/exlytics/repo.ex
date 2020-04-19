defmodule Exlytics.Repo do
  use Ecto.Repo,
    otp_app: :exlytics,
    adapter: Ecto.Adapters.Postgres
end
