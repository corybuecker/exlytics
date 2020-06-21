defmodule Exlytics.MetadataParser do
  @moduledoc false
  @allowed_headers ["host", "origin", "referer", "user-agent"]

  @spec metadata_from_conn(Plug.Conn.t()) :: %{}
  def metadata_from_conn(%Plug.Conn{} = conn) do
    %{}
    |> Map.merge(map_from_headers(conn))
    |> Map.merge(map_from_query(conn))
    |> Map.merge(map_from_body(conn))
  end

  defp map_from_headers(%Plug.Conn{} = conn) do
    conn.req_headers
    |> Enum.reduce(%{}, fn {key, value}, acc -> acc |> Map.put(key, value) end)
    |> Enum.filter(fn {key, _value} -> Enum.member?(@allowed_headers, key) end)
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
      body |> Enum.into(%{})
    else
      _ -> %{}
    end
  end

  defp query_params_to_map(%Plug.Conn{} = conn) do
    conn.query_params
    |> Enum.filter(fn {key, _value} -> Enum.member?(@allowed_headers, key) end)
    |> Enum.into(%{})
  end
end
