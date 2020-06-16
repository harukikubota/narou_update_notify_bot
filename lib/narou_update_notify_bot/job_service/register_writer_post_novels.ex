defmodule NarouUpdateNotifyBot.JobService.RegisterWriterPostNovels do
  alias NarouUpdateNotifyBot.Repo
  alias Repo.{
    Novels,
    Writers
  }
  require Logger

  def exec(writer_id) do
    :timer.sleep(500)
    Logger.debug "start RegisterWriterPostNovels @writer_id: #{writer_id}"
    create_writer_post_novels(writer_id)
  end

  def create_writer_post_novels(writer_id) do
    writer = target(writer_id)

    fetch_writer_novels(writer.remote_id)
    |> Enum.reject(&(&1.ncode in (Map.get(writer, :novels)|> Enum.map(fn n -> n.ncode end))))
    |> Enum.map(&format!/1)
    |> Enum.map(&(Map.merge(&1, %{writer_id: writer.id})))
    |> Enum.map(&create/1)
  end

  def target(writer_id), do: Writers.select_for_register_post_novels(writer_id)

  def fetch_writer_novels(remote_id) do
    case Repo.Narou.find_by_userid(remote_id) do
      {:ok, _, results} -> results
    end
  end

  def format!(%{general_all_no: episode_id,
                general_lastup: remote_created_at,
                ncode:          ncode,
                title:          title
              }) do
    %{
      episode_id: episode_id,
      remote_created_at: remote_created_at,
      ncode: ncode,
      title: title
    }
  end

  def create(param) do
    Logger.debug "start_create! ncode:#{param.ncode}"
    spawn(Novels, :create_with_assoc_episode, [param])
  end
end
