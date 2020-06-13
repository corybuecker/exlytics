defmodule Exlytics.Data.Repo.Migrations.DropAccounts do
  use Ecto.Migration

  def up do
    drop(table(:accounts))
  end

  def down do
    create table(:accounts, [{:primary_key, false}]) do
      add(:id, :uuid, primary_key: true)
      timestamps()
    end
  end
end
