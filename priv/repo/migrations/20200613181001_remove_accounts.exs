defmodule Exlytics.Data.Repo.Migrations.RemoveAccounts do
  use Ecto.Migration

  def up do
    alter table(:events) do
      remove(:account_id)
    end
  end

  def down do
    alter table(:events) do
      add(:account_id, :uuid, null: true)
    end
  end
end
