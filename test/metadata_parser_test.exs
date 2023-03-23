defmodule Exlytics.MetadataParserTest do
  alias Exlytics.Utils.FakeTimeAdapter
  use ExUnit.Case, async: true
  use Plug.Test

  test "parses a GET request" do
    metadata =
      Plug.Test.conn(:get, "/")
      |> Plug.Conn.put_req_header("ip", "1.2.3.4")
      |> Exlytics.MetadataParser.metadata_from_conn()

    assert metadata == %{
             "host" => "www.example.com",
             "time" => FakeTimeAdapter.current_time()
           }
  end

  test "includes a timestamp" do
    metadata =
      Plug.Test.conn(:post, "/", %{test: true} |> Jason.encode!())
      |> Exlytics.MetadataParser.metadata_from_conn()

    assert Map.has_key?(metadata, "time")
  end

  test "parses a POST request" do
    metadata =
      Plug.Test.conn(:post, "/", %{test: true} |> Jason.encode!())
      |> Plug.Conn.put_req_header("ip", "1.2.3.4")
      |> Plug.Conn.put_req_header("content-type", "text/plain")
      |> Exlytics.MetadataParser.metadata_from_conn()

    assert metadata == %{
             "host" => "www.example.com",
             "test" => true,
             "time" => FakeTimeAdapter.current_time()
           }
  end

  test "converts hyphens to underscores" do
    metadata =
      Plug.Test.conn(:post, "/", %{"test-value" => true} |> Jason.encode!())
      |> Plug.Conn.put_req_header("user-agent", "localhost")
      |> Exlytics.MetadataParser.metadata_from_conn()

    assert metadata == %{
             "host" => "www.example.com",
             "user_agent" => "localhost",
             "test_value" => true,
             "time" => FakeTimeAdapter.current_time()
           }
  end

  test "handles an invalid body" do
    metadata =
      Plug.Test.conn(:post, "/?query=true", "this is not JSON")
      |> Plug.Conn.put_req_header("ip", "1.2.3.4")
      |> Plug.Conn.put_req_header("content-type", "text/plain")
      |> Exlytics.MetadataParser.metadata_from_conn()

    assert metadata == %{
             "host" => "www.example.com",
             "query" => "true",
             "time" => FakeTimeAdapter.current_time()
           }
  end
end
