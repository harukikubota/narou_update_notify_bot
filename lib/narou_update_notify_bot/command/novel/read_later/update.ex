defmodule NarouUpdateNotifyBot.Command.Novel.ReadLater.Update do
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

    case UserCallableState.judge(:read_later, :update, %{user_id: user.id, novel_id: novel.id}) do
      {:error} -> render_with_send(:error, dao, param.key)
      {:ok}    ->
        UsersReadLaterNovels.update_episode_id(user.id, novel.id, restart_episode_id)
        render_with_send(:ok, dao, param.key)
    end
  end
end
