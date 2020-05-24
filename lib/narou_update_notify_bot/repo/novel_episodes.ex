defmodule NarouUpdateNotifyBot.Repo.NovelEpisodes do
  import Ecto.Query
  alias NarouUpdateNotifyBot.Repo
  alias NarouUpdateNotifyBot.Entity.NovelEpisode

  def novel_last_episodes_query do
    from ne in NovelEpisode,
      order_by: [desc: ne.remote_created_at],
      distinct: ne.novel_id
  end

  def leatest_update_history(novel_id, limit \\ 10) do
    from(
      n in NovelEpisode,
      where: n.novel_id == ^novel_id,
      order_by: [desc: n.episode_id],
      select: %{episode_id: n.episode_id, created_at: n.remote_created_at},
      limit: ^limit
    ) |> Repo.all
  end

  def create(%{novel_id: novel_id, episode_id: episode_id, created: created}) do
    %NovelEpisode{}
    |> Map.merge(%{novel_id: novel_id, episode_id: episode_id, remote_created_at: created})
    |> Repo.insert!
  end
end
