defmodule Exlytics.Collector.Router do
  @moduledoc false

  alias Ecto.Adapters.SQL
  alias Exlytics.Collector.EventsRouter
  alias Exlytics.Data.Repo

  use Plug.Router
  require Logger

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  get "/healthcheck" do
    case SQL.query(Repo, "select 1", [], [{:log, false}]) do
      {:ok, _results} ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> send_resp(200, "{\"database\":true}")

      _ ->
        send_resp(conn, 500, "")
    end
  end

  match("/", to: EventsRouter)

  match _ do
    send_resp(conn, 404, "not found")
  end
end
