defmodule Exlytics.MetadataParser do
  @moduledoc false
  @allowed_headers ["origin", "referer", "user-agent"]

  @spec metadata_from_conn(Plug.Conn.t()) :: %{}
  def metadata_from_conn(%Plug.Conn{} = conn) do
    %{}
    |> Map.merge(map_from_connection(conn))
    |> Map.merge(map_from_headers(conn))
    |> Map.merge(map_from_query(conn))
    |> Map.merge(map_from_body(conn))
    |> Map.merge(%{"time" => Application.get_env(:exlytics, :time_adapter).current_time()})
  end

  defp map_from_connection(%Plug.Conn{host: host} = conn) do
    %{"host" => host}
  end

  defp map_from_headers(%Plug.Conn{} = conn) do
    conn.req_headers
    |> Enum.reduce(%{}, fn {key, value}, acc -> acc |> Map.put(key, value) end)
    |> Enum.filter(fn {key, _value} -> Enum.member?(@allowed_headers, key) end)
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      acc |> Map.put(key |> String.replace("-", "_"), value)
    end)
    |> Enum.into(%{})
  end

  defp map_from_query(%Plug.Conn{} = conn) do
    conn
    |> Plug.Conn.fetch_query_params()
    |> query_params_to_map()
  end

  defp map_from_body(%Plug.Conn{} = conn) do
    with {:ok, body, _conn} <- conn |> Plug.Conn.read_body(),
         {:ok, body} <- Jason.decode(body) do
      body
      |> Enum.into(%{})
      |> Enum.reduce(%{}, fn {key, value}, acc ->
        acc |> Map.put(key |> String.replace("-", "_"), value)
      end)
    else
      _ -> %{}
    end
  end

  defp query_params_to_map(%Plug.Conn{} = conn) do
    conn.query_params
    |> Enum.into(%{})
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      acc |> Map.put(key |> String.replace("-", "_"), value)
    end)
  end
end
