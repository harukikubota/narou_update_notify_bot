defmodule NarouUpdateNotifyBot.JobService.RegisterWriterPostNovels do
  alias NarouUpdateNotifyBot.Repo
  alias Repo.{
    Novels,
    Writers
  }
  require Logger

  def exec(writer_id) do
    :timer.sleep(500)
    Logger.info "start exec"
    create_writer_post_novels(writer_id)
  end

  def create_writer_post_novels(writer_id) do
    writer = target(writer_id)

    reject_target_novels_ncode = Map.get(writer, :novels) |> Enum.map(&(&1.ncode))

    unless length(reject_target_novels_ncode) == writer.novel_count do
      fetch_writer_novels(writer.remote_id)
      |> Enum.reject(&(&1.ncode in reject_target_novels_ncode))
      |> Enum.map(&format!/1)
      |> Enum.map(&(Map.merge(&1, %{writer_id: writer.id})))
      |> Enum.map(&create/1)
    end
  end

  def target(writer_id), do: Writers.select_for_register_post_novels(writer_id)

  def fetch_writer_novels(remote_id) do
    case Repo.Narou.find_by_userid(remote_id) do
      {:ok, _, results} -> results
    end
  end

  def format!(%{general_all_no: episode_id,
                general_lastup: remote_created_at,
                ncode: ncode,
                title: title
              }) do
    %{
      episode_id: episode_id,
      remote_created_at: remote_created_at,
      ncode: ncode,
      title: title
    }
  end

  def create(param) do
    Logger.info "start! #{param.ncode}"
    spawn(Novels, :create_with_assoc_episode, [param])
  end
end

[%{
  episode_id: 61,
  ncode: "n6458eg",
  remote_created_at: "2020-05-25 13:28:24",
  title: "設定鍵インベントリア：シャンフロの諸々",
  writer_id: 1
},
%{
  episode_id: 713,
  ncode: "n6169dz",
  remote_created_at: "2020-06-01 14:49:31",
  title: "シャングリラ・フロンティア〜クソゲーハンター、神ゲーに挑まんとす〜",
  writer_id: 1
}]
