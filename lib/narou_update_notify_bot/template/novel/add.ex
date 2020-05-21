defmodule NarouUpdateNotifyBot.Template.Novel.Add do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias NarouUpdateNotifyBot.Template.Common
  alias NarouUpdateNotifyBot.Template.Novel.Common, as: NCommon

  def render(:ok, dao), do: %M.Text{text: "「#{dao.novel.title}」を#{NCommon.to_jp(dao.type)}に追加しました。"}
  def render(:error, _), do: Common.render(:invalid_operation, nil)
end
