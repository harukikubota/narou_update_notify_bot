defmodule NarouUpdateNotifyBot.Template.Novel.ReadLater.Add do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias NarouUpdateNotifyBot.Template.Common

  def render(:ok, dao) do
    %M.Text{text:
      """
      「#{dao.novel.title}」を後で読むに追加しました。

      後で読む一覧から「再開する」を選択することで#{dao.restart_episode_id}話から読み始めることができます。
      """
    }
  end

  def render(:error, _), do: Common.render(:invalid_operation, nil)
end
