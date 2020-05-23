defmodule NarouUpdateNotifyBot.Repo.UsersCheckNovels do
  alias NarouUpdateNotifyBot.Repo
  alias NarouUpdateNotifyBot.Repo.Novels
  alias NarouUpdateNotifyBot.Entity.UserCheckNovel
  import Ecto.Query

  def registered?(user_id, novel_id, type) do
    !!(find(user_id, novel_id, type))
  end

  def link_to(user_id, novel_id) do
    UserCheckNovel.ch_update_notify(%UserCheckNovel{}, %{user_id: user_id, novel_id: novel_id}) |> Repo.insert!
  end

  def link_to(user_id, novel_id, restart_episode_id) do
    UserCheckNovel.ch_read_later(%UserCheckNovel{}, %{user_id: user_id, novel_id: novel_id, restart_episode_id: restart_episode_id}) |> Repo.insert!
  end

  def unlink_to(user_id, novel_id) do
    from(UserCheckNovel, where: [user_id: ^user_id, novel_id: ^novel_id]) |> Repo.delete_all
  end

  def find(user_id, novel_id, type) do
    type = to_string(type)
    from(UserCheckNovel, where: [user_id: ^user_id, novel_id: ^novel_id, type: ^type]) |> first() |> Repo.one()
  end

  def update_episode_id(user_id, novel_id, restart_episode_id) do
    from(UserCheckNovel,
      where:  [user_id: ^user_id, novel_id: ^novel_id, type: "read_later"],
      update: [set: [restart_episode_id: ^restart_episode_id]]
    ) |> Repo.update_all([])
  end

  def switch_notification(user_id, novel_id) do
    target = find(user_id, novel_id, :update_notify)

    if target do
      set = [do_notify: !target.do_notify, turn_off_notification_at: DateTime.utc_now]
      from(n in UserCheckNovel,
        where: n.user_id == ^user_id and n.novel_id == ^novel_id
      )
      |> Repo.update_all(set: set)
      {:ok, Novels.novel_detail("update_notify", user_id, novel_id)}
    else
      {:error}
    end

  end
end
