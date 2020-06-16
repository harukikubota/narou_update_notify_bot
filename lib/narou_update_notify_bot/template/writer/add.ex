defmodule NarouUpdateNotifyBot.Template.Writer.Add do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias NarouUpdateNotifyBot.Template.Common

  def render(:ok, dao),                    do: %M.Text{text: "#{dao.writer.name}を更新通知に追加しました"}
  def render(:registration_limit_over, _), do: %M.Text{text: "登録上限に達しています。\n新しく登録するには削除してから登録してください。"}
  def render(:error, _),                   do: Common.render(:invalid_operation, nil)
end
