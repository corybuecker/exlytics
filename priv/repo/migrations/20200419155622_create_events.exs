defmodule Exlytics.Data.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    execute("CREATE SCHEMA IF NOT EXISTS exlytics")

    create table(:events, [{:primary_key, false}]) do
      add(:time, :utc_datetime_usec, null: false)
      add(:metadata, :map)
      timestamps()
    end

    create(index(:events, ["time", "metadata"]))
    create(index(:events, ["metadata"], using: :gin))
  end
end
