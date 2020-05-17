defmodule NarouUpdateNotifyBot.Command.Novel.ReadLater.Delete do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.{Novels, UsersReadLaterNovels}
  alias NarouUpdateNotifyBot.Command.Novel.Helper.UserCallableState

  def call(param) do
    user = Helper.current_user(param.user_id)
    novel = Novels.find(param.data.novel_id)
    dao = %{novel: novel}

    case UserCallableState.judge(:read_later, :delete, %{user_id: user.id, novel_id: novel.id}) do
      {:error} -> render_with_send(:error, dao, param.key)
      {:ok}    ->
        UsersReadLaterNovels.unlink_to(user.id, novel.id)
        render_with_send(:ok, dao, param.key)
    end
  end
end
