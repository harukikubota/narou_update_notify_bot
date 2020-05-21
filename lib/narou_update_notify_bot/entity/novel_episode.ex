defmodule NarouUpdateNotifyBot.Entity.NovelEpisode do
  use Ecto.Schema
  import Ecto.Changeset
  alias NarouUpdateNotifyBot.Entity.{User, Writer, UserCheckNovel}

  schema "novel_episodes" do
    field :episode_id, :integer
    field :remote_created_at, :naive_datetime

    timestamps()

    belongs_to :novel, Novel
  end
end
