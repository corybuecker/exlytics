defmodule Exlytics.EventsRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Ecto.Adapters.SQL.Sandbox
  alias Exlytics.Storage.Postgresql.{Event, Repo}

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "saves a GET event" do
    Plug.Test.conn(:get, "/")
    |> Plug.Conn.put_req_header("host", "localhost")
    |> Plug.Conn.put_req_header("ip", "1.2.3.4")
    |> Plug.Conn.put_req_header("x-forwarded-proto", "https")
    |> Exlytics.EventsRouter.call([])

    event = Event |> Ecto.Query.last(:inserted_at) |> Repo.one()
    assert %Event{metadata: %{"host" => "localhost"}} = event
  end

  test "saves a POST event with a body" do
    Plug.Test.conn(:post, "/", %{test: true} |> Jason.encode!())
    |> Plug.Conn.put_req_header("host", "localhost")
    |> Plug.Conn.put_req_header("ip", "1.2.3.4")
    |> Plug.Conn.put_req_header("content-type", "text/plain")
    |> Plug.Conn.put_req_header("x-forwarded-proto", "https")
    |> Exlytics.EventsRouter.call([])

    event = Event |> Ecto.Query.last(:inserted_at) |> Repo.one()
    assert %Event{metadata: %{"host" => "localhost", "test" => true}} = event
  end
end
