defmodule NarouUpdateNotifyBot.Entity.UserCheckWriter do
  use Ecto.Schema
  import Ecto.Changeset
  alias NarouUpdateNotifyBot.Entity.{User, Writer}

  @primary_key false
  schema "users_check_writers" do
    belongs_to :user, User
    belongs_to :writer, Writer
    field :do_notify, :boolean
    field :turn_off_notification_at, :utc_datetime

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:user_id, :writer_id])
    |> Ecto.Changeset.validate_required([:user_id, :writer_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:writer_id)
  end
end
