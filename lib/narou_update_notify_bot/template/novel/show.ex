defmodule NarouUpdateNotifyBot.Template.Novel.Show do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias LineBot.Message.Flex, as: F
  import NarouUpdateNotifyBot.Template.Helper
  alias NarouUpdateNotifyBot.Template.Novel.Helper, as: NHelper

  def render(:ok, dao) do
    %F{
      altText: dao.novel.title,
      contents: template(dao)
    }
  end

  def template(dao) do
    %F.Bubble{
      header: header(dao.novel),
      body: body(dao.type, dao.novel),
      footer: footer(dao.type, dao.novel),
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

  def body("update_notify", novel) do
    body = %F.Box{
      layout: :vertical,
      contents: [
        novel_writer(novel),
        latest_episode_info(novel)
      ]
    }
    # TODO 通知オフなら未読件数
  end

  def body("read_later", novel) do
    %F.Box{
      layout: :vertical,
      contents: [
        novel_writer(novel),
        restart_episode_info(novel)
      ]
    }
  end

  def novel_writer(novel) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Button{
          action: %M.Action.Postback{
            data: postback_data(%{action: "/writer/show", writer_id: novel.writer_id}),
            label: novel.writer.name
          }
        }
      ]
    }
  end

  def latest_episode_info(novel) do
    %F.Box{
      layout: :horizontal,
      contents: [
        %F.Text{
          text: "最新話 #{novel.last_episode.episode_id}",
          action: %M.Action.URI{
            uri: add_opt_open_url_link(NHelper.make_novel_url(novel.ncode, novel.last_episode.episode_id))
          },
          color: "#325b85",
          flex: 5
        },
        %F.Text{
          text: format_date_yymmddhhmi(novel.last_episode.remote_created_at),
          flex: 7
        }
      ]
    }
  end

  def restart_episode_info(novel) do
    %F.Box{
      layout: :horizontal,
      contents: [
        %F.Text{
          text: "#{novel.check_user.restart_episode_id}話  #{format_date_yymmddhhmi(novel.check_user.updated_at)}",
          align: :center
        }
      ]
    }
  end

  def footer(type, novel) do
    %F.Box{
      layout: :vertical,
      contents: [footer_top_area(type, novel), footer_bottom_area(type, novel)] |> Enum.reject(&(is_nil &1))
    }
  end

  def footer_top_area("update_notify", novel) do
    contents =
      if novel.check_user.do_notify do
        [button_show_update_history(novel.id)]
      else
        [button_show_update_history(novel.id),button_read_update_history(novel.id)]
      end
    %F.Box{
      layout: :horizontal,
      contents: contents
    }
  end

  def footer_bottom_area("update_notify", novel) do
    %F.Box{
      layout: :horizontal,
      contents: [
        %F.Button{
          action: %M.Action.Postback{
            data: postback_data(%{action: "/novel/switch_notification", novel_id: novel.id}),
            label: "通知" <> NHelper.notification_flag_to_jp(!novel.check_user.do_notify)
          }
        },
        button_novel_delete(novel.id, "update_notify")
      ]
    }
  end

  def footer_top_area("read_later", novel) do
    %F.Box{
      layout: :horizontal,
      contents: [
        %F.Button{
          action: %M.Action.URI{
            uri: add_opt_open_url_link(NHelper.make_novel_url(novel.ncode, novel.check_user.restart_episode_id)),
            label: "再開する"
          }
        },
        button_novel_delete(novel.id, "read_later")
      ]
    }
  end

  def footer_bottom_area("read_later", _), do: nil

  def button_novel_delete(novel_id, type) do
    %F.Button{
      action: %M.Action.Postback{
        data: postback_data(%{action: "/novel/delete", novel_id: novel_id, type: type}),
        label: "削除する"
      }
    }
  end

  def button_show_update_history(novel_id) do
    %F.Button{
      action: %M.Action.Postback{
        data: postback_data(%{action: "/novel/show_update_history", novel_id: novel_id}),
        label: "更新履歴"
      }
    }
  end

  def button_read_update_history(novel_id) do
    %F.Button{
      action: %M.Action.Postback{
        data: postback_data(%{action: "/novel/read_update_history", novel_id: novel_id}),
        label: "未読を読む"
      }
    }
  end
end
