defmodule Exlytics.Data.Repo.Migrations.AddInitialAccount do
  use Ecto.Migration
  alias Exlytics.Data.{Account, Event, Repo}

  def up do
    %Account{id: account_id} = %Account{} |> Repo.insert!()
    Repo.update_all(Event, set: [account_id: account_id])
  end

  def down do
    Repo.update_all(Event, set: [account_id: nil])
  end
end
