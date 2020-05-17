defmodule NarouUpdateNotifyBot.Entity.UserReadLaterNovel do
  use Ecto.Schema
  import Ecto.Changeset
  alias NarouUpdateNotifyBot.Entity.{User, Novel}

  @primary_key false
  schema "users_read_later_novels" do
    belongs_to :user, User
    belongs_to :novel, Novel
    field :restart_episode_id, :integer

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:user_id, :novel_id, :restart_episode_id])
    |> validate_required([:user_id, :novel_id, :restart_episode_id])
    |> validate_number(:restart_episode_id, greater_than: 0)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:novel_id)
  end
end
