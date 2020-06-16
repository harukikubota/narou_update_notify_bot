defmodule NarouUpdateNotifyBot.Repo.Migrations.CreateNotificationInfo do
  use Ecto.Migration

  def change do
    create table(:notification_facts) do
      add :status,       :integer, null: false
      add :error_reason, :varchar
      add :type,         :string,  null: false

      add :user_id,          references(:users)
      add :novel_episode_id, references(:novel_episodes)
      add :novel_id,         references(:novels)
      add :writer_id,        references(:writers)

      timestamps()
    end

    create index(:notification_facts, [:user_id, :type], primary_key: true)
  end
end
