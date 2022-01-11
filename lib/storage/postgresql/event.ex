defmodule Exlytics.Storage.Postgresql.Event do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  # @schema_prefix "exlytics"
  schema "events" do
    field(:time, :utc_datetime_usec, null: false)
    field(:metadata, :map)
    timestamps()
  end

  def changeset(event, params \\ %{}) do
    event
    |> cast(params, [:metadata])
    |> set_time()
  end

  defp set_time(changeset) do
    changeset |> put_change(:time, DateTime.now!("Etc/UTC"))
  end
end
