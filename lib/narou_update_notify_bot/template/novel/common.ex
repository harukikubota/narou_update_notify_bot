defmodule NarouUpdateNotifyBot.Template.Novel.Common do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M

  def render(:invalid_operation, dao), do: %M.Text{text: "無効な操作です。"}
end
