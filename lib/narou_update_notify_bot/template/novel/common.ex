defmodule NarouUpdateNotifyBot.Template.Novel.Common do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M

  def render(:invalid_operation, dao), do: %M.Text{text: "無効な操作です。"}

  def to_jp(type) do
    case type do
      "update_notify" -> "更新通知"
      "read_later"    -> "後で読む"
    end
  end
end
