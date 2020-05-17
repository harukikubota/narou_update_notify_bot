defmodule NarouUpdateNotifyBot.Repo.Migrations.CreateUserReadLaterNovel do
  use Ecto.Migration

  def change do
    create table(:users_read_later_novels) do
      add :user_id, references(:users)
      add :novel_id, references(:novels)
      add :restart_episode_id, :integer

      timestamps()
    end

    create index(:users_read_later_novels, [:user_id, :novel_id], primary_key: true)
  end
end
