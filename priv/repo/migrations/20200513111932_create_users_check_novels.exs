defmodule NarouUpdateNotifyBot.Repo.Migrations.CreateUserCheckNovels do
  use Ecto.Migration

  def change do
    create table(:users_check_novels) do
      add :user_id, references(:users)
      add :novel_id, references(:novels)
      add :do_notify, :boolean, default: true
      add :turn_off_notification_at, :utc_datetime
      add :restart_episode_id, :integer
      add :type, :string

      timestamps()
    end

    create index(:users_check_novels, [:user_id, :novel_id], primary_key: true)
  end
end
