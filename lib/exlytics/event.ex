defmodule Exlytics.Event do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "events" do
    # field(:account_id, Ecto.UUID, null: false)
    field(:time, :utc_datetime_usec, null: false)
    # field(:url, :string, null: false)
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
