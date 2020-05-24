defmodule NarouUpdateNotifyBot.Repo.Migrations.CreateRichMenu do
  use Ecto.Migration

  def change do
    create table(:rich_menus) do
      add :remote_id, :string, null: false
      add :name,      :string, null: false
    end
  end
end
