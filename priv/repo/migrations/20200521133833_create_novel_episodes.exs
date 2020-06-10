defmodule NarouUpdateNotifyBot.Repo.Migrations.CreateNovelEpisodes do
  use Ecto.Migration

  def change do
    create table(:novel_episodes) do
      add :novel_id,          references(:novels)
      add :episode_id,        :integer
      add :remote_created_at, :utc_datetime
      add :remote_deleted_at, :utc_datetime
      add :remote_deleted,    :boolean

      timestamps()
    end
  end
end
