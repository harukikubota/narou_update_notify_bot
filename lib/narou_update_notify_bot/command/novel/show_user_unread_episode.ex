defmodule NarouUpdateNotifyBot.Command.Novel.ShowUserUnreadEpisode do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.{
    Novels,
    UsersCheckNovels,
    NotificationFacts
  }

  def call(param) do
    user_id  = Helper.current_user(param.user_id).id
    {_, novel} = Novels.novel_detail(:one, user_id, param.data.novel_id)
    dao = %{novel: novel}

    if String.to_atom(param.data.confirm) do
      render_with_send(:confirm, dao, param.key)
    else
      unread_episodes = NotificationFacts.user_unread_episodes(user_id, novel.id)

      case unread_episodes do
        [] -> render_with_send(:no_unread, dao, param.key)
        _  ->
          NotificationFacts.change_status_all(unread_episodes, "notificated")
          dao = Map.merge(dao, %{unread_episodes: unread_episodes})
          render_with_send(:unread_episodes, dao, param.key)
      end
    end
  end
end
