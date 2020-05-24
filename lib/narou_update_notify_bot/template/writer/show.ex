defmodule NarouUpdateNotifyBot.Template.Writer.Show do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias LineBot.Message.Flex, as: F
  import NarouUpdateNotifyBot.Template.Helper
  alias NarouUpdateNotifyBot.Template.Writer.Helper, as: WHelper


  def render(type, writer) do
    %F{
      altText: writer.name,
      contents: template(type, writer)
    }
  end

  def template(type, writer) do
    %F.Bubble{
      header: header(writer),
      body:   body(type, writer),
      footer: footer(type, writer),
      styles: %F.BubbleStyle{
        body:   %F.BubbleStyleBlock{ separator: true, separatorColor: "#020202" },
        footer: %F.BubbleStyleBlock{ separator: true, separatorColor: "#020202" }
      }
    }
  end

  def header(writer) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Text{
          text: writer.name,
          color: "#325b85",
          align: :center
        }
      ],
      action: %M.Action.URI{
        uri: add_opt_open_url_link(WHelper.make_writer_mypage_url(writer.remote_id))
      }
    }
  end

  def body(:ok, writer) do
    %F.Box{
      layout: :vertical,
      contents: [user_register_associated_novels(writer)]
    }
  end

  def body(:no_registered, _) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Box{
          layout: :vertical,
          contents: [
            %F.Text{ text: "未登録の作者", align: :center }
          ]
        }
      ]
    }
  end

  def user_register_associated_novels(writer) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Text{ text: "登録している小説一覧", align: :center }
      ] ++ Enum.map(writer.novels, &register_associated_novel/1)
    }
  end

  def register_associated_novel(novel) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Button{
          style: :link,
          action: %M.Action.Postback{
            label: "• #{novel.title}",
            data: postback_data(%{
              action: "/novel/show",
              novel_id: novel.id,
              type: novel.type
            })
          }
        }
      ]
    }
  end

  def footer(:ok, writer) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Button{
          action: %M.Action.Postback{
            data: postback_data(%{action: "/writer/delete", writer_id: writer.id}),
            label: "削除する"
          }
        }
      ]
    }
  end

  def footer(:no_registered, writer) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Button{
          action: %M.Action.Postback{
            data: postback_data(%{action: "/writer/add", writer_id: writer.id}),
            label: "更新通知に登録する"
          }
        }
      ]
    }
  end
end
