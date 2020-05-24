defmodule NarouUpdateNotifyBot.Command.Writer.Show do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.Writers

  def call(param) do
    user = Helper.current_user(param.user_id)
    writer = Writers.writer_detail(user.id, param.data.writer_id)

    if writer do
      render_with_send(:ok, writer, param.key)
    else
      render_with_send(:no_registered, Writers.find(param.data.writer_id), param.key)
    end
  end
end
