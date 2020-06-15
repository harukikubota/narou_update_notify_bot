defmodule NarouUpdateNotifyBot.Template.JobService.Notificate_data do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias LineBot.Message.Flex, as: F
  import NarouUpdateNotifyBot.Template.Helper
  alias NarouUpdateNotifyBot.Template.Novel.Helper, as: NHelper
  alias NarouUpdateNotifyBot.Template.Writer.Helper, as: WHelper

  def render(:ok, notification_facts) do
    notification_facts
    |> Enum.map(&format!/1)
    |> compactize_to(:novel_new_episode)
    |> compactize_to(:delete_novel_episode)
    |> Enum.chunk_every(10)
    |> Enum.map(&col_template/1)
  end

  def format!(data) do
    (case data.type do
      n when n in [:novel_new_episode, :delete_novel_episode] ->
        %{novel: data.novel_episode.novel, episode: data.novel_episode}

      n when n in [:new_post_novel ,:delete_novel] ->
        %{novel: data.novel, writer: data.novel.writer}

      :delete_writer -> %{writer: data.writer}
    end)
    |> Map.merge(%{type: data.type})
  end

  def compactize_to(records, type) do
    {target, non_target_records} = Enum.split_with(records, &(&1.type == type))

    non_target_records ++ _compactize_to(target, type)
  end

  # :novel_new_episode || :delete_novel_episode
  def _compactize_to(records, type) do
    records
    |> Enum.group_by(&(&1.novel.id))
    |> Enum.map(fn {_, v} ->
      %{type: type, novel: hd(v).novel, episodes: Enum.map(v, &(&1.episode))}
    end)
  end

  def col_template(notification_facts) do
    %F{
      altText: "登録小説一覧",
      contents: %F.Carousel{
        contents: Enum.map(notification_facts, &(template_for(&1.type, &1)))
      }
    }
  end

  def template_for(:novel_new_episode, data) do
    %F.Bubble{
      header: header("エピソード更新"),
      body: body(:novel_new_episode, data),
      styles: %F.BubbleStyle{
        body: %F.BubbleStyleBlock{ separator: true, separatorColor: "#020202" }
      }
    }
  end

  def template_for(:delete_novel_episode, data) do
    %F.Bubble{
      header: header("エピソード削除"),
      body: body(:delete_novel_episode, data),
      styles: %F.BubbleStyle{
        body: %F.BubbleStyleBlock{ separator: true, separatorColor: "#020202" }
      }
    }
  end

  def template_for(:delete_writer, data) do
    %F.Bubble{
      header: header("作者退会"),
      body: body(:delete_writer, data),
      styles: %F.BubbleStyle{
        body: %F.BubbleStyleBlock{ separator: true, separatorColor: "#020202" }
      }
    }
  end

  def template_for(:delete_novel, data) do
    %F.Bubble{
      header: header("小説削除"),
      body: body(:delete_novel, data),
      styles: %F.BubbleStyle{
        body: %F.BubbleStyleBlock{ separator: true, separatorColor: "#020202" }
      }
    }
  end

  def template_for(:new_post_novel, data) do
    %F.Bubble{
      header: header("小説新規投稿"),
      body: body(:new_post_novel, data),
      footer: footer(:new_post_novel, data),
      styles: %F.BubbleStyle{
        body: %F.BubbleStyleBlock{ separator: true, separatorColor: "#020202" },
        footer: %F.BubbleStyleBlock{ separator: true, separatorColor: "#020202" }
      }
    }
  end


  def header(title) do
    %F.Box{
      layout: :horizontal,
      contents: [
        %F.Text{
          text: title,
          align: :center
        }
      ]
    }
  end

  def body(:novel_new_episode, %{novel: novel, episodes: episodes}) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Button{
          action: %M.Action.Postback{
            data: postback_data(%{action: "/novel/show", novel_id: novel.id}),
            label: novel.title
          }
        }
      ] ++ Enum.map(episodes, &(episode_link(novel, &1)))
    }
  end

  defp episode_link(novel, episode) do
    %F.Box{
      layout: :horizontal,
      contents: [
        %F.Text{
          text: "#{episode.episode_id}話",
          action: %M.Action.URI{
            uri: add_opt_open_url_link(NHelper.make_novel_url(novel.ncode, episode.episode_id))
          },
          color: "#325b85",
          flex: 3
        },
        %F.Text{
          text: format_date_yymmddhhmi(episode.remote_created_at),
          flex: 5
        }
      ]
    }
  end

  def body(:delete_novel_episode, %{novel: novel, episodes: episodes}) do
    episode_id =
      if length(episodes) == 1 do
        hd(episodes).episode_id
      else
        "#{hd(episodes).episode_id}~#{List.last(episodes).episode_id}"
      end

    %F.Box{
      layout: :vertical,
      contents: [
        %F.Button{
          action: %M.Action.Postback{
            data: postback_data(%{action: "/novel/show", novel_id: novel.id}),
            label: novel.title
          }
        },
        %F.Box{
          layout: :horizontal,
          contents: [%F.Text{text: "#{episode_id}話が削除されました。", wrap: true}]
        }
      ]
    }
  end

  def body(:delete_writer, %{writer: writer}) do
    %F.Box{
      layout: :vertical,
      contents: [
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
        },
        %F.Text{
          text: "作者が退会した可能性があります。",
          wrap: true
        }
      ]
    }
  end

  def body(:delete_novel, %{writer: writer, novel: novel}) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Button{
          action: %M.Action.Postback{
            data: postback_data(%{action: "/writer/show", writer_id: writer.id}),
            label: writer.name
          }
        },
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
        },
        %F.Text{
          text: "作者によって削除または検索除外設定にされました。",
          wrap: true
        }
      ]
    }
  end

  def body(:new_post_novel, %{writer: writer, novel: novel}) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Button{
          action: %M.Action.Postback{
            data: postback_data(%{action: "/writer/show", writer_id: writer.id}),
            label: writer.name
          }
        },
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
      ]
    }
  end

  def footer(:new_post_novel, %{novel: novel}) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Button{
          action: %M.Action.Postback{
            data: postback_data(%{action: "/novel/add", novel_id: novel.id, type: :update_notify}),
            label: "更新通知に追加する"
          },
          height: :sm,
          style: :link
        },
        %F.Button{
          action: %M.Action.Postback{
            data: postback_data(%{action: "/novel/add", novel_id: novel.id, episode_id: 1, type: :read_later}),
            label: "後で読むに追加する"
          },
          height: :sm,
          style: :link
        }
      ]
    }
  end

end
