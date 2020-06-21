defmodule Exlytics.MetadataParserTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "parses a GET request" do
    metadata =
      Plug.Test.conn(:get, "/")
      |> Plug.Conn.put_req_header("host", "localhost")
      |> Plug.Conn.put_req_header("ip", "1.2.3.4")
      |> Exlytics.MetadataParser.metadata_from_conn()

    assert metadata == %{"host" => "localhost"}
  end

  test "parses a POST request" do
    metadata =
      Plug.Test.conn(:post, "/", %{test: true} |> Jason.encode!())
      |> Plug.Conn.put_req_header("host", "localhost")
      |> Plug.Conn.put_req_header("ip", "1.2.3.4")
      |> Plug.Conn.put_req_header("content-type", "text/plain")
      |> Exlytics.MetadataParser.metadata_from_conn()

    assert metadata == %{"host" => "localhost", "test" => true}
  end
end
