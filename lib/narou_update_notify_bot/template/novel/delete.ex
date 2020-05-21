defmodule NarouUpdateNotifyBot.Template.Novel.Delete do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias NarouUpdateNotifyBot.Template.Common
  alias NarouUpdateNotifyBot.Template.Novel.Common, as: NCommon

  def render(:ok, dao),  do: %M.Text{text: "#{dao.novel.title}を#{NCommon.to_jp(dao.type)}から削除しました。"}
  def render(:error, _), do: Common.render(:invalid_operation, nil)
end
