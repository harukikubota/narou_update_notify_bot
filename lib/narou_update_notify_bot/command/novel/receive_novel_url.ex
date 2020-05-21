defmodule NarouUpdateNotifyBot.Command.Novel.ReceiveNovelUrl do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.{Novels, Users, UsersCheckNovels}

  def call(param) do
    case Novels.find_or_create_by(param.ncode) do
      {:no_data}   -> render_with_send(:no_data, nil, param.key)
      {:ok, novel} ->
        user = Users.find_by_line_id(param.user_id)
        episode_id = if param.episode_id == "", do: 1, else: param.episode_id
        dao = %{novel: novel, episode_id: episode_id}

        if UsersCheckNovels.registered?(user.id, novel.id, :update_notify) do
          render_with_send(:registered_update_notify, dao, param.key)
        else
          record = UsersCheckNovels.find(user.id, novel.id, :read_later)
          unless is_nil(record) do
            dao = %{old_episode_id: record.restart_episode_id} |> Map.merge(dao)

            render_with_send(:registered_read_later, dao, param.key)
          else
            render_with_send(:no_register, dao, param.key)
          end
        end
    end
  end
end
