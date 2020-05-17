defmodule NarouUpdateNotifyBot.Repo.UsersCheckNovels do
  alias NarouUpdateNotifyBot.Repo
  alias NarouUpdateNotifyBot.Entity.UserCheckNovel
  import Ecto.Query

  def registered?(user_id, novel_id) do
    !!(from(UserCheckNovel, where: [user_id: ^user_id, novel_id: ^novel_id]) |> first() |> Repo.one())
  end

  def link_to(user_id, novel_id) do
    UserCheckNovel.changeset(%UserCheckNovel{}, %{user_id: user_id, novel_id: novel_id}) |> Repo.insert!
  end

  def unlink_to(user_id, novel_id) do
    from(UserCheckNovel, where: [user_id: ^user_id, novel_id: ^novel_id]) |> Repo.delete_all
  end
end
