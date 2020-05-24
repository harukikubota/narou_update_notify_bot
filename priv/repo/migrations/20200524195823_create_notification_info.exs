defmodule NarouUpdateNotifyBot.Repo.Migrations.CreateNotificationInfo do
  use Ecto.Migration

  def change do
    create table(:notification_facts) do
      add :user_id, references(:users)
      add :status, :string, default: "inserted"
      add :error_reason, :varchar
      add :type, :string, null: false
    end
  end
end
