defmodule Exlytics.Router do
  @moduledoc false

  @firestore_collection "pageviews"
  @allowed_origins ["https://corybuecker.com", "https://integration.corybuecker.com"]
  @allowed_headers ["host", "origin", "referer", "user-agent"]

  use Plug.Router
  require Logger

  alias GoogleApi.Firestore.V1.Api.Projects
  alias GoogleApi.Firestore.V1.Connection
  alias GoogleApi.Firestore.V1.Model.Document
  alias GoogleApi.Firestore.V1.Model.Value

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> save_event()
    |> put_resp_header("content-type", "application/json")
    |> add_access_control_allow_origin_header()
    |> send_resp(200, "{}")
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end

  defp add_access_control_allow_origin_header(%Plug.Conn{} = conn) do
    with [origin] <- conn |> get_req_header("origin"),
         true <- @allowed_origins |> Enum.member?(origin) do
      conn |> put_resp_header("access-control-allow-origin", origin)
    else
      _ -> conn
    end
  end

  defp save_event(%Plug.Conn{} = conn) do
    {:ok, doc} =
      Projects.firestore_projects_databases_documents_create_document(
        google_connection(),
        Application.fetch_env!(:exlytics, :firestore_database),
        @firestore_collection,
        body: conn |> document()
      )

    Logger.info(doc |> inspect())

    conn
  end

  @spec google_connection() :: %Tesla.Client{}
  defp google_connection do
    token() |> Connection.new()
  end

  defp token do
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/datastore")
    token.token
  end

  defp document(%Plug.Conn{} = conn) do
    %Document{
      fields:
        req_headers_map(conn)
        |> Map.merge(query_params_map(conn))
        |> Map.merge(%{
          event_timestamp: %Value{timestampValue: DateTime.utc_now() |> DateTime.to_iso8601()}
        })
    }
  end

  def req_headers_map(%Plug.Conn{} = conn) do
    conn.req_headers |> filter_by_allowed() |> to_google_fields()
  end

  @spec filter_by_allowed(list(tuple())) :: list(tuple())
  defp filter_by_allowed(headers) do
    headers |> Enum.filter(fn {header, _value} -> Enum.member?(@allowed_headers, header) end)
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
