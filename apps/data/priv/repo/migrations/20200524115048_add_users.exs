defmodule Exlytics.Data.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users, [{:primary_key, false}]) do
      add(:id, :uuid, primary_key: true)
      add(:email, :string, required: true)
      add(:account_id, references(:accounts, type: :uuid, on_delete: :delete_all), required: true)
      timestamps()
    end

    create(index(:users, ["account_id"]))
  end
end
