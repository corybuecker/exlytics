defmodule Exlytics.Data.Repo.Migrations.GrantPermissionsToDashboard do
  use Ecto.Migration

  def up do
    execute("grant usage on schema exlytics to dashboard")
    execute("alter default privileges in schema exlytics grant select on tables to dashboard")
  end

  def down do
    execute("alter default privileges in schema exlytics revoke select on tables from dashboard")
    execute("revoke usage on schema exlytics from dashboard")
  end
end
