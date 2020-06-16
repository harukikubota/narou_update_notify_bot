defmodule NarouUpdateNotifyBot.Command.Novel.SwitchNotification do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.{
    Novels,
    UsersCheckNovels,
    NotificationFacts
  }
  require Logger

  def call(param) do
    user_id  = Helper.current_user(param.user_id).id
    {_, novel} = Novels.novel_detail(:one, user_id, param.data.novel_id)

    user_unread_count = NotificationFacts.user_unread_episode_count(user_id, novel.id)
    exec_delete_unread = !is_nil(Map.get(param.data, :do_delete))

    exec(param.key, user_id, novel, user_unread_count, exec_delete_unread)
    IO.inspect send(param.key)
  end

  def exec(key, user_id, novel, 0, _) do
    switch_notification(user_id, novel, key)
  end

  def exec(key, _, novel, user_unread_count, false) when user_unread_count > 0 do
      render(:confirm_delete_to_unread, %{novel: novel, unread_count: user_unread_count}, key)
  end

  def exec(key, user_id, novel, _, true) do
    unread_episodes = NotificationFacts.user_unread_episodes(user_id, novel.id)
    NotificationFacts.change_status_all(unread_episodes, "notificated")

    render(:unread_episodes, %{novel: novel, unread_episodes: unread_episodes}, key)
    switch_notification(user_id, novel, key)
  end

  def switch_notification(user_id, novel, key) do
    case UsersCheckNovels.switch_notification(user_id, novel.id) do
      {:error} -> render(:no_data, nil, key)
      {:ok}    ->
        {_, novel} = Novels.novel_detail(:one, user_id, novel.id)
        render(:ok, %{novel: novel}, key)
    end
  end
end
