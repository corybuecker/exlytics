defmodule Exlytics.Data.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    execute("create extension if not exists timescaledb", "")

    create table(:events, [{:primary_key, false}]) do
      add(:time, :utc_datetime_usec, null: false)
      add(:metadata, :map)
      timestamps()
    end

    execute("select create_hypertable('events', 'time')", "")

    create(index(:events, ["time", "metadata"]))
    create(index(:events, ["metadata"], using: :gin))
  end
end
