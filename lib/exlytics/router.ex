defmodule Exlytics.Router do
  @moduledoc false

  alias Exlytics.EventsRouter

  use Plug.Router
  require Logger

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  get "/healthcheck" do
    send_resp(conn, 200, "OK")
  end

  match("/", to: EventsRouter)

  match _ do
    send_resp(conn, 404, "not found")
  end
end
