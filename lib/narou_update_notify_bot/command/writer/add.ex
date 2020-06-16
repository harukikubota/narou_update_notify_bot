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
        if user.writer_register_max > UsersCheckWriters.user_register_count(user.id) do
          UsersCheckWriters.link_to(user.id, writer.id)
          render_with_send(:ok, %{writer: writer}, param.key)
        else
          render_with_send(:registration_limit_over, nil, param.key)
        end
    end
  end
end
