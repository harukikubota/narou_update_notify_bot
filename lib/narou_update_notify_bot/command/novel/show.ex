defmodule NarouUpdateNotifyBot.Command.Novel.Show do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.Novels

  def call(param) do
    user = Helper.current_user(param.user_id)
    novel = Novels.novel_detail(param.data.type, user.id, param.data.novel_id)

    if novel do
      render_with_send(:ok, %{novel: novel, type: param.data.type}, param.key)
    else
      render_with_send(:no_data, nil, param.key)
    end
  end
end
