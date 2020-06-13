defmodule Exlytics.Data.Repo.Migrations.AddAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, [{:primary_key, false}]) do
      add(:id, :uuid, primary_key: true)
      timestamps()
    end
  end
end
