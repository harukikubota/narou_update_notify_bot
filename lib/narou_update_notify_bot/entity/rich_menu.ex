defmodule NarouUpdateNotifyBot.Entity.RichMenu do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rich_menus" do
    field :remote_id, :string
    field :name,      :string
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:remote_id, :name])
    |> validate_required([:remote_id, :name])
  end
end
