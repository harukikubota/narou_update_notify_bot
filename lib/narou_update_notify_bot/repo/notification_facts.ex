defmodule NarouUpdateNotifyBot.Repo.NotificationFacts do
  import Ecto.Query
  alias NarouUpdateNotifyBot.Repo
  alias NarouUpdateNotifyBot.Entity.{
    User,
    Novel,
    NovelEpisode,
    UserCheckNovel,
    NotificationInfo
  }

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

  def create(params) do
    {%{type: type}, param} = params |> Map.split([:type])
    NotificationInfo.changeset(type, param)
    |> Repo.insert!
  end

  def change_notification_off_novel_update_record_to_unread do
    from(
      ni in NotificationInfo,
      join: ne in NovelEpisode, on: ne.id == ni.novel_episode_id,
      join: ucn in UserCheckNovel, on: ucn.user_id == ni.user_id, on: ucn.novel_id == ne.novel_id,
      where: ucn.do_notify == false and ni.status == "inserted",
      select: [:id]
    )
    |> update_status("user_unread")
  end

  def inserted_records do
    from(
      ni in NotificationInfo,
      left_join: u    in assoc(ni, :user),          on: ni.user_id          == u.id,
      left_join: ne   in assoc(ni, :novel_episode), on: ni.novel_episode_id == ne.id,
      left_join: ne_n in assoc(ne, :novel),         on: ne.novel_id         == ne_n.id,
      left_join: n    in assoc(ni, :novel),         on: ni.novel_id         == n.id,
      left_join: n_w  in assoc(n,  :writer),        on: n.writer_id         == n_w.id,
      left_join: w    in assoc(ni, :writer),        on: ni.writer_id        == w.id,
      where: ni.status == "inserted",
      order_by: [ni.type, ne_n.ncode, ne.episode_id],
      preload: [
        novel_episode: {ne, novel: ne_n},
        novel:         {n, writer: n_w},
        writer:        w,
        user:          u
      ]
    ) |> Repo.all()
  end

  def user_unread_episodes(user_id, novel_id) do
    from(
      ni in NotificationInfo,
      left_join: ne in assoc(ni, :novel_episode),
      left_join: n in assoc(ne, :novel),
      where: ni.status == "user_unread" and n.id == ^novel_id and ni.user_id == ^user_id,
      order_by: [ne.novel_id, ne.episode_id]
    )
    |> Repo.all()
  end

  def user_unread_episode_count(user_id, novel_id) do
    from(
      ni in NotificationInfo,
      left_join: ne in assoc(ni, :novel_episode),
      left_join: n in assoc(ne, :novel),
      where: ni.status == "user_unread" and n.id == ^novel_id and ni.user_id == ^user_id,
      group_by: ne.novel_id,
      limit: 1,
      select: count(ne.novel_id)
    )
    |> Repo.one()
  end

  def update_status(update_target_fetch_query, status) do
    from(ni in NotificationInfo, where: ni.id in subquery(update_target_fetch_query))
    |> Repo.update_all(set: [status: status])
  end

  def reset_all do
    NotificationInfo
    |> select([n], n.id)
    |> update_status("inserted")
  end

  def change_status_all(records, status) do
    ids = records |> Enum.map(&(&1.id))

    from(ni in NotificationInfo, where: ni.id in ^ids, select: [:id])
    |> update_status(to_string(status))
  end

  def change_status_all(records, :error, reason) do
    ids = records |> Enum.map(&(&1.id)) |> Enum.sort

    from(ni in NotificationInfo, where: ni.id in subquery(
      from(ni in NotificationInfo, where: ni.id in ^ids, select: [:id])
    ))
    |> Repo.update_all(set: [status: "error", error_reason: inspect(reason)])
  end
end
