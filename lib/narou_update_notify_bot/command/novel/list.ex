defmodule NarouUpdateNotifyBot.Command.Novel.List do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.Novels

  def call(param) do
    user = Helper.current_user(param.user_id)
    type = param.data.type
    novels = Novels.novel_detail(:all, type, user.id)

    if length(novels) > 0 do
      render_with_send(:ok, %{novels: novels, type: type}, param.key)
    else
      render_with_send(:no_registered, nil, param.key)
    end
  end
end
