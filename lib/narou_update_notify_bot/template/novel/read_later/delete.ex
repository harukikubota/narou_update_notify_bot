defmodule NarouUpdateNotifyBot.Template.Novel.ReadLater.Delete do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias NarouUpdateNotifyBot.Template.Common

  def render(:ok, dao),  do: %M.Text{text: "#{dao.novel.title}を後で読むから削除しました。"}
  def render(:error, _), do: Common.render(:invalid_operation, nil)
end
