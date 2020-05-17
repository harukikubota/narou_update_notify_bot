defmodule NarouUpdateNotifyBot.Repo.UsersReadLaterNovels do
  alias NarouUpdateNotifyBot.Repo
  alias NarouUpdateNotifyBot.Entity.UserReadLaterNovel
  import Ecto.Query

  def registered?(user_id, novel_id) do
    !!(find(user_id, novel_id))
  end

  def link_to(user_id, novel_id, restart_episode_id) do
    UserReadLaterNovel.changeset(%UserReadLaterNovel{}, %{user_id: user_id, novel_id: novel_id, restart_episode_id: restart_episode_id}) |> Repo.insert!
  end

  def unlink_to(user_id, novel_id) do
    from(UserReadLaterNovel, where: [user_id: ^user_id, novel_id: ^novel_id]) |> Repo.delete_all
  end

  def update_episode_id(user_id, novel_id, restart_episode_id) do
    from(UserReadLaterNovel,
      where:  [user_id: ^user_id, novel_id: ^novel_id],
      update: [set: [restart_episode_id: ^restart_episode_id]]
    ) |> Repo.update_all([])
  end

  def find(user_id, novel_id) do
    from(UserReadLaterNovel, where: [user_id: ^user_id, novel_id: ^novel_id]) |> first() |> Repo.one()
  end
end
