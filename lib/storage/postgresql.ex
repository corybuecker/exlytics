defmodule Exlytics.Storage.Postgresql do
  @moduledoc false

  alias Exlytics.Storage.Postgresql.Event
  alias Exlytics.Storage.Postgresql.Repo
  require Logger

  def save(event) when is_map(event) do
    with changeset <-
           Event.changeset(%Event{}, %{
             metadata: event
           }) do
      Logger.info(changeset |> inspect())
      changeset |> Repo.insert()
    end
  end
end
