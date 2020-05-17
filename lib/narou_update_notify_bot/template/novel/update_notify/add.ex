defmodule NarouUpdateNotifyBot.Template.Novel.UpdateNotify.Add do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias NarouUpdateNotifyBot.Template.Novel.Common

  def render(:ok, dao) do
    %M.Text{text: "#{dao.novel.title}を更新通知に追加しました"}
  end

  def render(:error, _), do: Common.render(:invalid_operation, nil)
end
