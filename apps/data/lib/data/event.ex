defmodule Exlytics.Data.Event do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Exlytics.Data.{Account, Repo}

  @primary_key false

  schema "events" do
    field(:time, :utc_datetime_usec, null: false)
    field(:metadata, :map)
    timestamps()

    belongs_to(:account, Account, type: Ecto.UUID)
  end

  def changeset(event, params \\ %{}) do
    event
    |> cast(params, [:metadata, :account_id])
    |> validate_required([:account_id])
    |> validate_change(:account_id, &account_exists?/2)
    |> set_time()
  end

  defp set_time(changeset) do
    changeset |> put_change(:time, DateTime.now!("Etc/UTC"))
  end

  defp account_exists?(:account_id, account_id) do
    case from(a in Account, where: a.id == ^account_id) |> Repo.exists?() do
      true -> []
      false -> [account_id: "not found"]
    end
  end
end
