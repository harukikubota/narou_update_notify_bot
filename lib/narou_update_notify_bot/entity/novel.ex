defmodule NarouUpdateNotifyBot.Entity.Novel do
  use Ecto.Schema
  import Ecto.Changeset
  alias NarouUpdateNotifyBot.Entity.{User, NovelEpisode, Writer, UserCheckNovel}

  schema "novels" do
    field :ncode, :string
    field :title, :string
    field :remote_deleted, :boolean, default: false
    field :remote_deleted_at, :utc_datetime

    timestamps()

    belongs_to   :writer,       Writer
    has_one      :last_episode, NovelEpisode
    has_one      :check_user,   UserCheckNovel
    has_many     :episodes,     NovelEpisode
    many_to_many :users,        User, join_through: UserCheckNovel
  end

  def changeset(novel, attrs) do
    novel
    |> cast(attrs, [:ncode, :title])
    |> validate_required([:ncode, :title])
    |> validate_length(:title, min: 2)
    |> validate_format(:ncode, Narou.Util.ncode_format())
    |> unique_constraint(:ncode)
  end

  def changeset(:remote_deleted, novel, attrs) do
    novel
    |> cast(attrs, [:remote_deleted, :remote_deleted_at])
    |> validate_required([:remote_deleted, :remote_deleted_at])
  end
end
