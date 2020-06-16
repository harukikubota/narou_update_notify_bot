defmodule NarouUpdateNotifyBot.Repo.Migrations.CreateWriters do
  use Ecto.Migration

  def change do
    create table(:writers) do
      add :remote_id, :integer
      add :name, :string, null: false
      add :remote_deleted, :boolean, default: false
      add :remote_deleted_at, :utc_datetime

      timestamps()
    end

    create unique_index(:writers, [:remote_id], unique: true)
  end
end
