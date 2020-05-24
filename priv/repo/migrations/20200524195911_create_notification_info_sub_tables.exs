defmodule NarouUpdateNotifyBot.Repo.Migrations.CreateNotificationInfoSubTables do
  use Ecto.Migration

  def change do
    create table(:notification_info_novel_new_episodes, options: "INHERITS (notification_facts)") do
      add :novel_episode_id, references(:novel_episodes)
    end

    create table(:notification_info_new_post_novels, options: "INHERITS (notification_facts)") do
      add :novel_id, references(:novels)
    end

    create table(:notification_info_delete_novels, options: "INHERITS (notification_facts)") do
      add :novel_id, references(:novels)
    end

    create table(:notification_info_delete_novel_episodes, options: "INHERITS (notification_facts)") do
      add :novel_id, references(:novels)
      add :episode_id, :integer
    end

    create table(:notification_info_delete_writers, options: "INHERITS (notification_facts)") do
      add :writer_id, references(:writers)
    end
  end
end
