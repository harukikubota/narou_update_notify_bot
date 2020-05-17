defmodule NarouUpdateNotifyBot.Entity.Writer do
  use Ecto.Schema
  import Ecto.Changeset
  alias NarouUpdateNotifyBot.Entity.{User, Novel, UserCheckWriter}

  schema "writers" do
    field :remote_id, :integer
    field :name, :string, null: false
    field :novel_count, :integer, null: false
    field :remote_deleted, :boolean, default: false
    field :remote_deleted_at, :utc_datetime

    timestamps()

    has_many :novels, Novel
    many_to_many :users, User, join_through: UserCheckWriter

    def changeset(writer, attr) do
      writer
      |> cast(attr, [:remote_id, :name, :novel_count])
      |> validate_required([:remote_id, :name, :novel_count])
      |> validate_number(:remote_id, greater_than: 0)
      |> validate_number(:novel_count, greater_than: 0)
      |> validate_length(:name, greater_than: 1)
      |> unique_constraint(:remote_id)
    end

    def changeset(:remote_deleted, novel, attrs) do
      novel
      |> cast(attrs, [:remote_deleted, :remote_deleted_at])
      |> validate_required([:remote_deleted, :remote_deleted_at])
    end
  end
end
