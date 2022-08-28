defmodule Exlytics.EventsRouter do
  @moduledoc false

  use Plug.Router
  require Logger

  plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], host: Application.fetch_env!(:exlytics, :host))
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
    |> save_event_for_conn()
    |> Plug.Conn.put_resp_header("x-robots-tag", "noindex, nofollow")
    |> send_resp(201, "")
  end

  defp save_event_for_conn(%Plug.Conn{} = conn) do
    conn
    |> Exlytics.MetadataParser.metadata_from_conn()
    |> Application.get_env(:exlytics, :cache).save()

    conn
  end
end
