defmodule NarouUpdateNotifyBot.JobService.FetchWritersAndCreateNotificationFactsSpec do
  use ESpec
  alias NarouUpdateNotifyBot.JobService.FetchWritersAndCreateNotificationFacts, as: Job
  alias NarouUpdateNotifyBot.Repo.{
    Writers
  }

  before base_fetch_data: %{episode_id: 332,
                            ncode: "n6715cb",
                            remote_created_at: "2020-06-07 22:02:43",
                            title: "未来の君に、さよなら",
                            writer_remote_id: 430311
                          }

  before fetched_empty_data: %{},
    ws1: Writers.find_by_ids_with_novels([430311]),
    novel_deleted: %{430311 => []},
    new_post_novel: %{
      430311 => [%{
        episode_id: 1,
        ncode: "n1111a",
        remote_created_at: "2020-10-10 10:10:10",
        title: "新規投稿小説",
        writer_remote_id: 430311
      },
      shared.base_fetch_data
    ]
    },
    novel_new_episode: %{
      430311 => [Map.merge(shared.base_fetch_data, %{episode_id: 333})]
    },
    delete_novel_episode: %{
      430311 => [Map.merge(shared.base_fetch_data, %{episode_id: 331})]
    },
    extract_tags: fn result -> Enum.map(result, &(elem(&1, 0))) end

  describe "#tagging_with" do
    context "writer_deleted" do
      let :res, do: Job.tagging_with(shared.fetched_empty_data, shared.ws1)
      it do: expect shared.extract_tags.(res()) |> to(eq [:writer_deleted])
    end

    context "novel_deleted" do
      let :res, do: Job.tagging_with(shared.novel_deleted, shared.ws1)
      it do: expect shared.extract_tags.(res()) |> to(eq [:novel_deleted])
    end

    context "new_post_novel" do
      let :res, do: Job.tagging_with(shared.new_post_novel, shared.ws1)
      it do: expect shared.extract_tags.(res()) |> to(eq [:novel_no_update, :new_post_novel])
    end

    context "novel_new_episode" do
      let :res, do: Job.tagging_with(shared.novel_new_episode, shared.ws1)
      it do: expect shared.extract_tags.(res()) |> to(eq [:novel_new_episode])
    end

    context "delete_novel_episode" do
      let :res, do: Job.tagging_with(shared.delete_novel_episode, shared.ws1)
      it do: expect shared.extract_tags.(res()) |> to(eq [:delete_novel_episode])
    end
  end
end
