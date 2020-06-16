defmodule NarouUpdateNotifyBot.Template.Writer.Delete do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  # TODO コモンを移動
  alias NarouUpdateNotifyBot.Template.Common

  def render(:ok, dao), do: %M.Text{text: "#{dao.writer.name}を更新通知から削除しました"}
  def render(:error, _), do: Common.render(:invalid_operation, nil)
end
