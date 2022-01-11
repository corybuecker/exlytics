defmodule Exlytics.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Ecto.Adapters.SQL.Sandbox
  alias Exlytics.Storage.Postgresql.Repo

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "healthcheck" do
    conn = Plug.Test.conn(:get, "/healthcheck") |> Exlytics.Router.call(%{})
    assert %Plug.Conn{status: 200} = conn
  end

  test "event" do
    conn =
      Plug.Test.conn(:get, "/")
      |> Plug.Conn.put_req_header("x-forwarded-proto", "https")
      |> Exlytics.Router.call(%{})

    assert %Plug.Conn{status: 201} = conn
  end

  test "404" do
    conn = Plug.Test.conn(:get, "/healthchecks") |> Exlytics.Router.call(%{})
    assert %Plug.Conn{status: 404} = conn
  end
end
