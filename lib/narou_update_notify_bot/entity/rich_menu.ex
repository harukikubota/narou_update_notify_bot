defmodule NarouUpdateNotifyBot.Entity.RichMenu do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rich_menus" do
    field :remote_id, :string
    field :name,      :string
  end
end
