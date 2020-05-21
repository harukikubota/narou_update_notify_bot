defmodule NarouUpdateNotifyBot.Command.Novel.SwitchNotification do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.UsersCheckNovels

  def call(param) do
    case UsersCheckNovels.switch_notification(Helper.current_user(param.user_id).id, param.data.novel_id) do
      {:ok, novel} -> render_with_send(:ok, %{novel: novel}, param.key)
      {:error}     -> render_with_send(:no_data, nil, param.key)
    end
  end
end
