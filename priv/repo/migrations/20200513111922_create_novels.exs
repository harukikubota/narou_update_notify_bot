defmodule NarouUpdateNotifyBot.Repo.Migrations.CreateNovels do
  use Ecto.Migration

  def change do
    create table(:novels) do
      add :writer_id, references(:writers)
      add :ncode, :string
      add :title, :string
      add :episode_count, :integer
      add :remote_deleted, :boolean, default: false
      add :remote_deleted_at, :utc_datetime
      add :remote_updated_at, :utc_datetime

      timestamps()
    end

    create unique_index(:novels, [:ncode, :title], unique: true)
  end
end
