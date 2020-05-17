defmodule NarouUpdateNotifyBot.Command.Novel.ReadLater.Add do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.{
    UsersReadLaterNovels,
    Novels
  }
  alias NarouUpdateNotifyBot.Command.Novel.Helper.UserCallableState

  def call(param) do
    user = Helper.current_user(param.user_id)
    novel = Novels.find(param.data.novel_id)
    restart_episode_id = param.data.episode_id

    dao = %{novel: novel, restart_episode_id: restart_episode_id}

    case UserCallableState.judge(:read_later, :add, %{user_id: user.id, novel_id: novel.id}) do
      {:error} -> render_with_send(:error, dao, param.key)
      {:ok}    ->
        UsersReadLaterNovels.link_to(user.id, novel.id, restart_episode_id)
        render_with_send(:ok, dao, param.key)
    end
  end
end
