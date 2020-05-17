defmodule NarouUpdateNotifyBot.Entity.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias NarouUpdateNotifyBot.Entity.{Novel, Writer, UserCheckNovel, UserCheckWriter}

  schema "users" do
    field :line_id, :string, null: false
    field :enabled, :boolean, default: true

    many_to_many :novels, Novel, join_through: UserCheckNovel
    many_to_many :writers, Writer, join_through: UserCheckWriter
  end

  def changeset(user, attr \\ %{}) do
    user
    |> cast(attr, [:line_id, :enabled])
    |> validate_required([:line_id])
    |> unique_constraint(:line_id)
  end
end