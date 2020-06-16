defmodule NarouUpdateNotifyBot.Command.Novel.Add do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.{
    UsersCheckNovels,
    Novels
  }
  alias NarouUpdateNotifyBot.Command.Novel.Helper.UserCallableState

  def call(param) do
    user = Helper.current_user(param.user_id)
    novel = Novels.find(param.data.novel_id)
    type = param.data.type
    dao = %{novel: novel, type: type}

    case UserCallableState.judge(:read_later, :add, %{user_id: user.id, novel_id: novel.id}) do
      {:error} -> render_with_send(:error, dao, param.key)
      {:ok}    ->

        if user.novel_register_max > UsersCheckNovels.user_register_count(type, user.id) do
          case type do
            "update_notify" -> UsersCheckNovels.link_to(user.id, novel.id)
            "read_later"    ->
              restart_episode_id = param.data.episode_id

              UsersCheckNovels.link_to(user.id, novel.id, restart_episode_id)
              dao = Map.merge(dao, %{restart_episode_id: restart_episode_id})
          end
          render_with_send(:ok, dao, param.key)
        else
          render_with_send(:registration_limit_over, dao, param.key)
        end
    end
  end
end
