defmodule NarouUpdateNotifyBot.Template.Common do
  use NarouUpdateNotifyBot.Template

  def render(:invalid_operation, _), do: %LineBot.Message.Text{text: "無効な操作です。"}
end
