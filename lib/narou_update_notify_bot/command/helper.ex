defmodule NarouUpdateNotifyBot.Command.Helper do
  alias NarouUpdateNotifyBot.Repo.Users

  def current_user(line_id), do: Users.find_by_line_id(line_id)
end
