defmodule NarouUpdateNotifyBot.Command.Novel.Delete do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.{Novels, UsersCheckNovels}
  alias NarouUpdateNotifyBot.Command.Novel.Helper.UserCallableState

  def call(param) do
    user = Helper.current_user(param.user_id)
    novel = Novels.find(param.data.novel_id)
    type = param.data.type
    dao = %{novel: novel, type: type}

    case UserCallableState.judge(type, :delete, %{user_id: user.id, novel_id: novel.id}) do
      {:error} -> render_with_send(:error, dao, param.key)
      {:ok}    ->
        UsersCheckNovels.unlink_to(user.id, novel.id)
        render_with_send(:ok, dao, param.key)
    end
  end
end
