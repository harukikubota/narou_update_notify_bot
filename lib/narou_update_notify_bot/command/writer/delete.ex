defmodule NarouUpdateNotifyBot.Command.Writer.Delete do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.{Writers, UsersCheckWriters}
  alias NarouUpdateNotifyBot.Command.Writer.Helper.UserCallableState

  def call(param) do
    user = Helper.current_user(param.user_id)
    writer = Writers.find(param.data.writer_id)

    case UserCallableState.judge(:delete, %{user_id: user.id, writer_id: writer.id}) do
      {:error} -> render_with_send(:error, nil, param.key)
      {:ok}    ->
        UsersCheckWriters.unlink_to(user.id, writer.id)
        render_with_send(:ok, %{writer: writer}, param.key)
    end
  end
end
