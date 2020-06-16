defmodule NarouUpdateNotifyBot.Command.Novel.Show do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.Novels

  def call(param) do
    user = Helper.current_user(param.user_id)
    {user_register_status, novel} = Novels.novel_detail(:one, user.id, param.data.novel_id)

    type = case user_register_status do
      :registered   -> novel.check_user.type
      :no_register -> "no_register"
    end

    render_with_send(:ok, %{novel: novel, type: type}, param.key)
  end
end
