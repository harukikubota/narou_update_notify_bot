defmodule NarouUpdateNotifyBot.Template.Novel.Show do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias LineBot.Message.Flex, as: F
  import NarouUpdateNotifyBot.Template.Helper
  alias NarouUpdateNotifyBot.Template.Novel.Helper, as: NHelper

  def render(:ok, dao) do
    ret = %F{
      altText: dao.novel.title,
      contents: template(dao)
    }
  end

  def render(:no_data), do: %M.Text{ text: "登録されていない小説です。"}

  def template(dao) do
    %F.Bubble{
      header: header(dao.novel),
      body: body(dao.novel, dao.type),
      footer: footer(dao.novel, dao.type),
      styles: %F.BubbleStyle{
        body: %F.BubbleStyleBlock{ separator: true, separatorColor: "#020202" },
        footer: %F.BubbleStyleBlock{ separator: true, separatorColor: "#020202" }
      }
    }
  end

  def header(novel) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Text{
          text: novel.title,
          color: "#325b85",
          align: :center
        }
      ],
      action: %M.Action.URI{
        uri: add_opt_open_url_link(NHelper.make_novel_url(novel.ncode))
      }
    }
  end

  def body(novel, type) do
    body = %F.Box{
      layout: :vertical,
      contents: [
        novel_writer(novel),
        latest_episode_info(novel)
      ]
    }

    # 作者リンク
    # 最新話の行
    # 通知オフなら未読件数
  end

  def novel_writer(novel) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Button{
          action: %M.Action.Postback{
            data: postback_data(%{action: "/writer/show", writer_id: novel.writer_id}),
            label: novel.writer_name
          }
        }
      ]
    }
  end

  def latest_episode_info(novel) do
    %F.Box{
      layout: :baseline,
      contents: [
        %F.Text{ text: "最新話 #{novel.episode_id}" ,
          action: %M.Action.URI{
            uri: add_opt_open_url_link(NHelper.make_novel_url(novel.ncode, novel.episode_id))
          },
          color: "#325b85",
          align: :center
        },
        %F.Text{ text: format_date_yymmddhhmi(novel.remote_created_at) }
      ]
    }
  end

  def footer(novel, type) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Box{
          layout: :horizontal,
          contents: [
            %F.Button{
              action: %M.Action.Postback{
                data: postback_data(%{action: "/novel/show_update_history", novel_id: novel.id}),
                label: "更新履歴"
              }
            },
            %F.Button{
              action: %M.Action.Postback{
                data: postback_data(%{action: "/novel/read_update_history", novel_id: novel.id}),
                label: "更新分を読む"
              }
            }
          ]
        },
        %F.Box{
          layout: :horizontal,
          contents: [
            %F.Button{
              action: %M.Action.Postback{
                data: postback_data(%{action: "/novel/switch_notification", novel_id: novel.id, type: type}),
                label: "通知" <> NHelper.notification_flag_to_jp(!novel.do_notify)
              }
            },
            %F.Button{
              action: %M.Action.Postback{
                data: postback_data(%{action: "/novel/delete", novel_id: novel.id, type: type}),
                label: "削除する"
              }
            }
          ]
        }
      ]
    }
  end
end
