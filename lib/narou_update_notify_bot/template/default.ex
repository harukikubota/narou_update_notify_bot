defmodule NarouUpdateNotifyBot.Template.Default do
  use NarouUpdateNotifyBot.Template

  def render(:unsupported, _), do: %LineBot.Message.Text{text: "未対応です。"}
end
