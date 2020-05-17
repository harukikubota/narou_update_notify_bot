defmodule NarouUpdateNotifyBot.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :line_id, :string, null: false
      add :enabled, :boolean, default: false
    end

    create unique_index(:users, [:line_id], unique: true)
  end
end
