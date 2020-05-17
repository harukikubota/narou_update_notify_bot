defmodule NarouUpdateNotifyBot.Template.Novel.ReceiveNovelUrl do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message.Flex, as: F
  alias LineBot.Message, as: M
  import NarouUpdateNotifyBot.Template.Helper

  def render(:no_register, dao) do
    %{
      title: "未登録小説",
      actions: [action(:read_later_add, dao), action(:update_notify_add, dao)],
      date: format_date_yymmddhhmi(dao.novel.remote_updated_at)
    } |> Map.merge(dao)
    |> _template()
  end

  def render(:registered_read_later, dao) do
    %{
      title: "後で読む小説",
      actions: [
        action(:read_later_update, dao),
        action(:read_later_delete, dao),
        action(:update_notify_add, dao)
      ],
      date: format_date_yymmddhhmi(dao.novel.remote_updated_at)
    } |> Map.merge(dao)
    |> _template()
  end

  def render(:registered_update_notify, dao) do
    %{
      title: "更新通知小説",
      actions: [action(:update_notify_delete, dao)],
      date: format_date_yymmddhhmi(dao.novel.remote_updated_at)
    } |> Map.merge(dao)
    |> _template()
  end

  def render(:no_data, _dao) do
    %M.Text{text: "存在しない小説か、作者によって検索除外に設定されています。"}
  end

  defp action(:read_later_add, dao) do
    _action(%{action: "/novel/read_later/add", novel_id: dao.novel.id, episode_id: dao.episode_id}, "後で読むに追加する")
  end

  defp action(:update_notify_add, dao), do: _action(%{action: "/novel/read_later/change_to_update_notify", novel_id: dao.novel.id}, "更新通知に変更する")

  defp action(:read_later_update, dao) do
    label = "再開位置更新 :  #{dao.old_episode_id} |> #{dao.episode_id}"
    _action(%{action: "/novel/read_later/update", novel_id: dao.novel.id, episode_id: dao.episode_id}, label)
  end
  defp action(:read_later_delete, dao), do: _action(%{action: "/novel/read_later/delete", novel_id: dao.novel.id}, "後で読むから削除する")
  defp action(:update_notify_delete, dao), do: _action(%{action: "/novel/update_notify/delete", novel_id: dao.novel.id}, "更新通知から削除する")

  defp _template(dao) do
    %F{
      altText: dao.title,
      contents: %F.Bubble{
        body: %F.Box{
          layout: :vertical,
          margin: :lg,
          spacing: :sm,
          contents: [
            %F.Text{
              align:  :center,
              size:   :xl,
              text:   dao.title,
              type:   :text,
              weight: :bold
            },
            %F.Box{
              layout: :vertical,
              margin: :lg,
              spacing: :sm,
              contents: [
                %F.Box{
                  layout: :baseline,
                  spacing: :sm,
                  contents: [
                    %F.Text{
                      align: :center,
                      color: "#666666",
                      size:  :md,
                      flex:  5,
                      text:  dao.novel.title,
                      wrap:  true
                    }
                  ]
                },
                %F.Box{
                  layout: :horizontal,
                  contents: [
                    %F.Text{
                      align: :center,
                      text:  "最終更新日 #{dao.date}",
                      wrap:  true
                    },
                    %F.Text{
                      align: :center,
                      color: "#e3a368",
                      gravity: :center,
                      text:  "最新話 #{dao.novel.episode_count}"
                    }
                  ]
                }
              ]
            }
          ]
        },
        footer: %F.Box{
          flex: 0,
          layout: :vertical,
          spacing: :sm,
          contents: dao.actions
        }
      }
    }
  end

  def _action(data, label) do
    %F.Button{
      action: %M.Action.Postback{
        data: postback_data(data),
        label: label
      },
      height: :sm,
      style: :link
    }
  end
end
