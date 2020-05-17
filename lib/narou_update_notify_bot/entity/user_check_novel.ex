defmodule NarouUpdateNotifyBot.Entity.UserCheckNovel do
  use Ecto.Schema
  import Ecto.Changeset
  alias NarouUpdateNotifyBot.Entity.{User, Novel}

  @primary_key false
  schema "users_check_novels" do
    belongs_to :user, User
    belongs_to :novel, Novel
    field :do_notify, :boolean
    field :turn_off_notification_at, :utc_datetime

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:user_id, :novel_id])
    |> validate_required([:user_id, :novel_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:novel_id)
  end
end
