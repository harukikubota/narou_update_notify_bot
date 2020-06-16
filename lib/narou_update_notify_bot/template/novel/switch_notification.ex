defmodule NarouUpdateNotifyBot.Template.Novel.SwitchNotification do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias LineBot.Message.Flex, as: F
  import NarouUpdateNotifyBot.Template.Helper
  alias NarouUpdateNotifyBot.Template.Novel.Helper, as: NHelper
  alias NarouUpdateNotifyBot.Template.Novel.ShowUserUnreadEpisode

  def render(:ok, dao) do
    %M.Text{ text: "「#{dao.novel.title}」の通知を#{NHelper.notification_flag_to_jp(dao.novel.check_user.do_notify)}にしました。" }
  end

  def render(:confirm_delete_to_unread, %{novel: novel, unread_count: unread_count}) do
    %F{
      altText: "通知切替の確認",
      contents: %F.Bubble{
        header: %F.Box{
          layout: :vertical,
          contents: [
            %F.Text{
              text: "通知切替の確認",
              align: :center
            }
          ]
        },
        body: %F.Box{
          layout: :vertical,
          contents: [
            %F.Box{
              layout: :horizontal,
              contents: [
                %F.Text{
                  text: """
                        「#{novel.title}」の未読エピソードが#{unread_count}件存在します。
                        「未読の表示＆削除」を選択した場合、未読エピソードの表示と削除が行われた後に小説の通知がオンになります。
                        """ |> String.trim_trailing(),
                  wrap: true,
                }
              ]
            }
          ]
        },
        footer: %F.Box{
          layout: :vertical,
          contents: [
            %F.Button{
              action: %M.Action.Postback{
                data: postback_data(%{action: "/novel/switch_notification", novel_id: novel.id, do_delete: true}),
                label: "未読の表示＆削除"
              }
            }
          ]
        }
      }
    }
  end

  def render(:unread_episodes, dao) do
    ShowUserUnreadEpisode.render(:unread_episodes, dao)
  end

  def render(:no_data), do: %M.Text{ text: "登録されていない小説です。"}
end
