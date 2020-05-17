defmodule NarouUpdateNotifyBot.Command.User.Follow do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.Users

  def call(param) do
    case Users.find_or_create_by(param.user_id) do
      {:ok, _}      -> render_with_send(:hello, nil, param.key)
      {:created, user} ->
        Users.enable_to(user)
        render_with_send(:welcome_back, nil, param.key)
    end
  end
end
