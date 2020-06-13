defmodule Exlytics.Data.Repo.Migrations.AddAccountsToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add(:account_id, :uuid, required: false)
    end
  end
end
