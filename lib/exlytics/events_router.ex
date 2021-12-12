defmodule Exlytics.EventsRouter do
  @moduledoc false

  alias Exlytics.Data.{Event, Repo}

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
    with changeset <-
           Event.changeset(%Event{}, %{
             metadata: conn |> Exlytics.MetadataParser.metadata_from_conn()
           }) do
      Logger.info(changeset |> inspect())
      changeset |> Repo.insert()
    end

    conn
  end
end
