defmodule Exlytics.Collector.EventsRouter do
  @moduledoc false
  @allowed_origins [
    "https://corybuecker.com",
    "https://integration.corybuecker.com",
    "http://localhost:5000"
  ]
  @allowed_headers ["host", "origin", "referer", "user-agent"]
  alias Exlytics.Data.{Event, Repo}

  use Plug.Router
  require Logger

  plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], host: Application.fetch_env!(:collector, :host))

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn |> process_event()
  end

  post "/" do
    conn |> process_event()
  end

  defp process_event(%Plug.Conn{} = conn) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> add_access_control_allow_origin_header()
    |> save_event_for_conn()
    |> send_resp(200, "{}")
  end

  @spec add_access_control_allow_origin_header(%Plug.Conn{}) :: %Plug.Conn{}
  defp add_access_control_allow_origin_header(%Plug.Conn{} = conn) do
    with [origin] <- conn |> get_req_header("origin"),
         true <- @allowed_origins |> Enum.member?(origin) do
      conn |> put_resp_header("access-control-allow-origin", origin)
    else
      _ -> conn
    end
  end

  @spec save_event_for_conn(%Plug.Conn{}) :: %Plug.Conn{}
  defp save_event_for_conn(%Plug.Conn{} = conn) do
    Event.changeset(%Event{}, conn |> document())
    |> (fn changeset ->
          Logger.info(changeset |> inspect())
          changeset
        end).()
    |> Repo.insert()

    conn
  end

  defp document(%Plug.Conn{} = conn) do
    %{
      metadata:
        req_headers_map(conn)
        |> Map.merge(query_params_map(conn))
    }
  end

  defp req_headers_map(%Plug.Conn{} = conn) do
    conn.req_headers |> filter_by_allowed() |> to_fields()
  end

  @spec filter_by_allowed(list(tuple())) :: list(tuple())
  defp filter_by_allowed(headers) do
    headers
    |> Enum.filter(fn {header, _value} ->
      Enum.member?(@allowed_headers, header)
    end)
  end

  @spec query_params_map(%Plug.Conn{}) :: map()
  defp query_params_map(%Plug.Conn{} = conn) do
    conn = conn |> fetch_query_params()

    conn.query_params |> to_fields()
  end

  defp to_fields(values) when is_list(values) or is_map(values) do
    Enum.reduce(values, %{}, fn {key, value}, acc ->
      acc |> Map.put(key, value)
    end)
  end
end
