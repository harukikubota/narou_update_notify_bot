defmodule NarouUpdateNotifyBot.Entity.Novel do
  use Ecto.Schema
  import Ecto.Changeset
  alias NarouUpdateNotifyBot.Entity.{User, Writer, UserCheckNovel}

  schema "novels" do
    field :ncode, :string
    field :title, :string
    field :episode_count, :integer
    field :remote_deleted, :boolean, default: false
    field :remote_deleted_at, :utc_datetime
    field :remote_updated_at, :utc_datetime

    timestamps()

    belongs_to :writer, Writer
    many_to_many :users, User, join_through: UserCheckNovel
  end

  def changeset(novel, attrs) do
    novel
    |> cast(attrs, [:ncode, :title, :episode_count, :remote_updated_at])
    |> validate_required([:ncode, :title, :episode_count, :remote_updated_at])
    |> validate_length(:title, min: 2)
    |> validate_number(:episode_count, greater_than: 0)
    |> validate_format(:ncode, Narou.Util.ncode_format())
    |> unique_constraint(:ncode)
    |> format_jpdate_to_utc()
  end

  def changeset(:remote_deleted, novel, attrs) do
    novel
    |> cast(attrs, [:remote_deleted, :remote_deleted_at])
    |> validate_required([:remote_deleted, :remote_deleted_at])
  end

  def format_jpdate_to_utc(ch) do
    date =
      get_change(ch, :remote_updated_at)
      |> DateTime.add(3600 * -9)

    put_change(ch, :remote_updated_at, date)
  end
end
