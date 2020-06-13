defmodule Exlytics.Data.Repo.Migrations.NullableAccounts do
  use Ecto.Migration

  def up do
    alter table(:events) do
      modify(:account_id, :uuid, null: true)
    end
  end

  def down do
    alter table(:events) do
      modify(:account_id, :uuid, null: false)
    end
  end
end
