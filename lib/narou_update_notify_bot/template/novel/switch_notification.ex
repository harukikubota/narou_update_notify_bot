defmodule NarouUpdateNotifyBot.Template.Novel.SwitchNotification do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias NarouUpdateNotifyBot.Template.Novel.Helper, as: NHelper

  def render(:ok, dao) do
    %M.Text{ text: "「#{dao.novel.title}」の通知を#{NHelper.notification_flag_to_jp(dao.novel.check_user.do_notify)}にしました。" }
  end

  def render(:no_data), do: %M.Text{ text: "登録されていない小説です。"}
end
