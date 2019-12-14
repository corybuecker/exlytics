defmodule Exlytics.Router do
  @moduledoc false
  @firestore_database "projects/corybuecker-com/databases/(default)/documents"

  use Plug.Router
  require Logger

  alias GoogleApi.Firestore.V1.Api.Projects
  alias GoogleApi.Firestore.V1.Connection
  alias GoogleApi.Firestore.V1.Model.Document
  alias GoogleApi.Firestore.V1.Model.Value

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn |> async_save_pageview(DateTime.utc_now() |> DateTime.to_iso8601())

    conn
    |> put_resp_header("content-type", "application/json")
    |> put_resp_header("access-control-allow-origin", "https://corybuecker.com")
    |> send_resp(200, "{}")
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end

  defp async_save_pageview(%Plug.Conn{} = conn, event_timestamp) do
    Task.start(fn ->
      {:ok, doc} =
        Projects.firestore_projects_databases_documents_create_document(
          google_connection(),
          @firestore_database,
          "pageviews",
          body: conn |> document(event_timestamp)
        )

      Logger.info(doc |> inspect())
    end)
  end

  defp google_connection do
    token() |> Connection.new()
  end

  defp token do
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/datastore")
    token.token
  end

  defp document(%Plug.Conn{} = conn, event_timestamp) do
    %Document{
      fields:
        req_headers_map(conn)
        |> Map.merge(query_params_map(conn))
        |> Map.merge(%{event_timestamp: %Value{timestampValue: event_timestamp}})
    }
  end

  def req_headers_map(%Plug.Conn{} = conn) do
    conn.req_headers |> to_google_fields()
  end

  def query_params_map(%Plug.Conn{} = conn) do
    conn = conn |> fetch_query_params()

    conn.query_params |> to_google_fields()
  end

  defp to_google_fields(values) when is_list(values) or is_map(values) do
    Enum.reduce(values, %{}, fn {key, value}, acc ->
      acc |> Map.put(key, %Value{stringValue: value})
    end)
  end
end
