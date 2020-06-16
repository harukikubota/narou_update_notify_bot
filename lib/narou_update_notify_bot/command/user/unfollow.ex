defmodule NarouUpdateNotifyBot.Command.User.Unfollow do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.Users

  def call(param) do
    Users.find_by_line_id(param.user_id) |> Users.disable_to()
  end
end
