defmodule NarouUpdateNotifyBot.Template.Writer.ReceiveWriterUrl do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message.Flex, as: F
  alias LineBot.Message, as: M
  import NarouUpdateNotifyBot.Template.Helper

  def render(:no_register, dao) do
    %{
      title: "未登録作者",
      actions: [action(:add, dao)],
    } |> Map.merge(dao)
    |> _template()
  end

  def render(:registered, dao) do
    %{
      title: "更新通知作者",
      actions: [action(:delete, dao)],
    } |> Map.merge(dao)
    |> _template()
  end

  def render(:no_data, _), do: %M.Text{text: "存在しない作者か、作者によって検索除外に設定されています。"}

  defp action(:add, dao), do: _action(%{action: "/writer/add", writer_id: dao.writer.id}, "更新通知に登録する")
  defp action(:delete, dao), do: _action(%{action: "/writer/delete", writer_id: dao.writer.id}, "更新通知から削除する")

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
                %F.Text{
                  align: :center,
                  color: "#666666",
                  size:  :md,
                  text:  dao.writer.name
                },
                %F.Text{
                  align: :center,
                  text:  "投稿数 #{dao.writer.novel_count}"
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
