defmodule NarouUpdateNotifyBot.Template.Novel.ReadLater.Update do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias NarouUpdateNotifyBot.Template.Common

  def render(:ok, dao),  do: %M.Text{text: "再開位置を更新しました"}
  def render(:error, _), do: Common.render(:invalid_operation, nil)
end
