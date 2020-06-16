defmodule NarouUpdateNotifyBot.Template.User.ShowRegistrationInfo do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M

  def render(:ok, dao) do
    %M.Text{
      text: String.trim_trailing """
          【登録状況】

      ・後で読む小説  #{dao.novel_read_later_count}/#{dao.novel_register_max}
      ・更新通知小説  #{dao.novel_update_notify_count}/#{dao.novel_register_max}
      ・更新通知作者  #{dao.writer_update_notify_count}/#{dao.writer_register_max}
      """
    }
  end
end
