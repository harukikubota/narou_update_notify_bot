defmodule NarouUpdateNotifyBot.Repo.NotificationFacts do
  import Ecto.Query
  alias NarouUpdateNotifyBot.Repo
  alias NarouUpdateNotifyBot.Entity.{
    User,
    Novel,
    NovelEpisode,
    Writer,
    NotificationInfo
  }

  # 全部のテーブル結合するクエリ書く
  def _all() do
    from  n0 in NotificationInfo
    #select: {n0, n1, n2, n3, n4, n5}
  end

  def all() do
    from(
      ni in NotificationInfo,
      left_join: ne   in assoc(ni, :novel_episode), on: ni.novel_episode_id == ne.id,
      left_join: ne_n in assoc(ne, :novel),         on: ne.novel_id         == ne_n.id,
      left_join: n    in assoc(ni, :novel),         on: ni.novel_id         == n.id,
      left_join: n_w  in assoc(n,  :writer),        on: n.writer_id         == n_w.id,
      left_join: w    in assoc(ni, :writer),        on: ni.writer_id        == w.id,
      preload: [
        novel_episode: {ne, novel: ne_n},
        novel: {n, writer: n_w},
        writer: w
      ]
    ) |> Repo.all()
  end

  # params = %{novel_episode_id: 2, type: :novel_new_episode, user_id: 1}
  def create(params) do
    {%{type: type}, param} = params |> Map.split([:type])
    NotificationInfo.changeset(type, param)
    |> Repo.insert!
  end

end
