defmodule Exlytics.Storage.Postgresql do
  require Logger

  def save(event) when is_map(event) do
    with changeset <-
           Exlytics.Storage.Postgresql.Event.changeset(%Exlytics.Storage.Postgresql.Event{}, %{
             metadata: event
           }) do
      Logger.info(changeset |> inspect())
      changeset |> Exlytics.Storage.Postgresql.Repo.insert()
    end
  end
end
