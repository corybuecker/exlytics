defmodule Exlytics.EventsRouter do
  @moduledoc false

  @allowed_headers ["host", "origin", "referer", "user-agent"]

  alias Exlytics.Data.{Event, Repo}

  use Plug.Router
  require Logger

  plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], host: Application.fetch_env!(:exlytics, :host))

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn |> fetch_query_params() |> process_event()
  end

  post "/" do
    conn |> fetch_query_params() |> process_event()
  end

  defp process_event(%Plug.Conn{} = conn) do
    conn
    |> save_event_for_conn()
    |> send_resp(201, "")
  end

  @spec save_event_for_conn(%Plug.Conn{}) :: %Plug.Conn{}
  defp save_event_for_conn(%Plug.Conn{} = conn) do
    with changeset <- Event.changeset(%Event{}, conn |> document()) do
      Logger.info(changeset |> inspect())
      changeset |> Repo.insert()
    end

    conn
  end

  defp document(%Plug.Conn{} = conn) do
    body = conn |> body_map()

    %{
      "metadata" =>
        req_headers_map(conn)
        |> Map.merge(query_params_map(conn))
        |> Map.merge(body |> Enum.into(%{}))
        |> Enum.into(%{})
    }
  end

  defp req_headers_map(%Plug.Conn{} = conn) do
    conn.req_headers
    |> to_fields()
    |> Enum.filter(fn {key, _value} -> Enum.member?(@allowed_headers, key) end)
    |> Enum.into(%{})
  end

  defp body_map(%Plug.Conn{} = conn) do
    with {:ok, body, _conn} <- conn |> read_body(),
         {:ok, body} <- Jason.decode(body) do
      body
    else
      _ -> %{}
    end
  end

  @spec query_params_map(%Plug.Conn{}) :: map()
  defp query_params_map(%Plug.Conn{} = conn) do
    conn.query_params
    |> to_fields()
    |> Enum.into(%{})
  end

  defp to_fields(values) when is_list(values) or is_map(values) do
    Enum.reduce(values, %{}, fn {key, value}, acc ->
      acc |> Map.put(key, value)
    end)
  end
end
