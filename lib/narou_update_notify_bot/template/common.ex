defmodule NarouUpdateNotifyBot.Template.Common do
  use NarouUpdateNotifyBot.Template

  def render(:invalid_operation, _), do: %LineBot.Message.Text{text: "未対応です。"}
end
