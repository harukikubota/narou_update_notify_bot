defmodule NarouUpdateNotifyBot.Template.User.Follow do
  use NarouUpdateNotifyBot.Template

  def render(:hello, _),        do: %LineBot.Message.Text{text: "友達登録ありがとうございます"}
  def render(:welcome_back, _), do: %LineBot.Message.Text{text: "おかえりなさい"}
end
