defmodule NarouUpdateNotifyBot.Repo.Migrations.CreateUserCheckWriters do
  use Ecto.Migration

  def change do
    create table(:users_check_writers) do
      add :user_id, references(:users)
      add :writer_id, references(:writers)
      add :do_notify, :boolean, default: true
      add :turn_off_notification_at, :utc_datetime

      timestamps()
    end

    create index(:users_check_writers, [:user_id, :writer_id], primary_key: true)
  end
end
