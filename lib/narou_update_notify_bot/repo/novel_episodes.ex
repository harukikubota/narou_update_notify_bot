defmodule NarouUpdateNotifyBot.Repo.NovelEpisodes do
  import Ecto.Query
  alias NarouUpdateNotifyBot.Repo
  alias Repo.Util
  alias NarouUpdateNotifyBot.Entity.Helper
  alias NarouUpdateNotifyBot.Entity.NovelEpisode

  def novel_last_episodes_query do
    from ne in NovelEpisode,
      order_by: [desc: ne.episode_id],
      distinct: ne.novel_id,
      where: ne.remote_deleted == false
  end

  def leatest_update_history(novel_id, limit \\ 10) do
    from(
      n in NovelEpisode,
      where: n.novel_id == ^novel_id and n.remote_deleted == false,
      order_by: [desc: n.episode_id],
      select: %{episode_id: n.episode_id, created_at: n.remote_created_at},
      limit: ^limit
    ) |> Repo.all
  end

  def create(%{novel_id: novel_id, episode_id: episode_id, remote_created_at: created}) do
    %NovelEpisode{}
    |> Map.merge(%{novel_id: novel_id, episode_id: episode_id, remote_created_at: created})
    |> Helper.format_jpdate_to_utc(:remote_created_at)
    |> Repo.insert!
  end

  def delete(id) do
    Repo.get(NovelEpisode, id)
    |> Util.exec_delete()
  end

  def delete_by_novel(novel_id, episode_id) do
    from(
      ne in NovelEpisode,
      where: ne.novel_id == ^novel_id and ne.episode_id == ^episode_id and ne.remote_deleted == false
    )
    |> first()
    |> Repo.one()
    |> Util.exec_delete()
  end
end
