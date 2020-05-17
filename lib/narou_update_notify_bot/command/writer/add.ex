defmodule NarouUpdateNotifyBot.Command.Writer.Add do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.{
    UsersCheckWriters,
    Writers
  }
  alias NarouUpdateNotifyBot.Command.Writer.Helper.UserCallableState

  def call(param) do
    user = Helper.current_user(param.user_id)
    writer = Writers.find(param.data.writer_id)

    case UserCallableState.judge(:add, %{user_id: user.id, writer_id: writer.id}) do
      {:error} -> render_with_send(:error, nil, param.key)
      {:ok}    ->
        UsersCheckWriters.link_to(user.id, writer.id)
        render_with_send(:ok, %{writer: writer}, param.key)
    end
  end
end
