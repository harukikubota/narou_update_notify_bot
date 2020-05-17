defmodule NarouUpdateNotifyBot.Template.Novel.UpdateNotify.Add do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias NarouUpdateNotifyBot.Template.Common

  def render(:ok, dao),  do: %M.Text{text: "#{dao.novel.title}を更新通知に追加しました"}
  def render(:error, _), do: Common.render(:invalid_operation, nil)
end
