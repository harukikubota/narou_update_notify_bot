defmodule NarouUpdateNotifyBot.Template.Novel.ShowUserUnreadEpisode do
  use NarouUpdateNotifyBot.Template
  alias LineBot.Message, as: M
  alias LineBot.Message.Flex, as: F
  import NarouUpdateNotifyBot.Template.Helper
  alias NarouUpdateNotifyBot.Template.Novel.Helper, as: NHelper

  def render(:no_unread, %{novel: novel}) do
    %M.Text{text: "「#{novel.title}」の未読エピソードはありません。"}
  end

  def render(:confirm, %{novel: novel}) do
    %F{
      altText: "未読エピソード表示の確認",
      contents: %F.Bubble{
        header: %F.Box{
          layout: :vertical,
          contents: [
            %F.Text{
              text: "未読エピソード表示の確認",
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
                        「#{novel.title}」の未読エピソードを表示します。
                        「未読の表示＆削除」を選択した場合、未読エピソードの表示と削除が行われます。
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
                data: postback_data(%{action: "/novel/show_user_unread_episode", novel_id: novel.id, confirm: false}),
                label: "未読の表示＆削除"
              }
            }
          ]
        }
      }
    }
  end

  def render(:unread_episodes, %{novel: novel, unread_episodes: unread_episodes}) do
    get_episode = fn fun -> fun.(unread_episodes).novel_episode end
    episodes =
      [&(List.last(&1)), &(hd(&1))]
      |> Enum.map(&(get_episode.(&1)))
      |> Enum.uniq_by(&(&1.id))
      |> Enum.zip([:new, :old])

    %F{
      altText: "未読エピソード表示「#{novel.title}」",
      contents: %F.Bubble{
        header: %F.Box{
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
        body: %F.Box{
          layout: :vertical,
          contents: Enum.map(episodes, fn {episode, kind} ->
            make_episode_info(novel, episode, kind)
          end)
        },
        styles: %F.BubbleStyle{
          body: %F.BubbleStyleBlock{ separator: true, separatorColor: "#020202" }
        }
      }
    }
  end

  def make_episode_info(novel, episode, kind) do
    %F.Box{
      layout: :vertical,
      contents: [
        %F.Text{
          text: "未読#{to_jp(:kind, kind)}話",
          align: :center,
          size: :md
        },
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
              flex: 7
            }
          ]
        }
      ]
    }
  end

  defp to_jp(:kind, :old), do: "最古"
  defp to_jp(:kind, :new), do: "最新"
end
