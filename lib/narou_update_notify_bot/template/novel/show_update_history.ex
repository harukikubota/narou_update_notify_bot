defmodule NarouUpdateNotifyBot.Template.Novel.ShowUpdateHistory do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias LineBot.Message.Flex, as: F
  import NarouUpdateNotifyBot.Template.Helper
  alias NarouUpdateNotifyBot.Template.Novel.Helper, as: NHelper

  def render(:ok, dao) do
    %F{
      altText: "更新履歴 " <> dao.novel.title,
      contents: %F.Bubble{
        header: header(dao.novel),
        body: body(dao.novel, dao.history),
        styles: %F.BubbleStyle{
          body: %F.BubbleStyleBlock{ separator: true, separatorColor: "#020202" }
        }
      }
    }
  end

  def header(novel) do
    %F.Box{
      layout: :vertical,
      contents: [%F.Text{ text: novel.title, align: :center }]
    }
  end

  def body(novel, histories) do
    %F.Box{
      layout: :vertical,
      contents: Enum.map(histories, &(history(novel, &1)))
    }
  end

  def history(novel, data) do
    %F.Box{
      layout: :horizontal,
      contents: [
        %F.Text{ text: "#{data.episode_id}話" ,
          action: %M.Action.URI{
            uri: add_opt_open_url_link(NHelper.make_novel_url(novel.ncode, data.episode_id))
          },
          color: "#325b85",
          flex: 4
        },
        %F.Text{
          text: format_date_yymmddhhmi(data.created_at),
          flex: 9
        }
      ],
      margin: :md
    }
  end
end
