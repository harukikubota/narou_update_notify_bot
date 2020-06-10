defmodule NarouUpdateNotifyBot.JobService.FetchWritersAndCreateNotificationFacts do
  alias NarouUpdateNotifyBot.Repo
  #alias NarouUpdateNotifyBot.Entity.Helper
  require Logger

  @child NarouUpdateNotifyBot.JobService.ApplyRemoteData
  @group_max_novel_cnt 2499

  def exec() do
    fetch_target_writers()
    |> grouping_writer_ids_to_fetch_data()
    |> Enum.map(&fetch_and_apply_remote_data/1)
  end

  defp fetch_target_writers(), do: Repo.Writers.records_to_fetch()

  defp grouping_writer_ids_to_fetch_data(writers) do
    writers
    |> add_index()
    |> Enum.group_by(&(elem(&1, 0)),&(elem(&1, 1)))
    |> Enum.map(fn {_,v} -> v end)
  end

  defp add_index(writers, group_id \\ 1, group_novel_cnt \\ 0)
  defp add_index([target|tail], group_id, group_novel_cnt) do
    current_count = target.novel_count + 1
    including_carry_over = current_count + group_novel_cnt

    {group_id, group_novel_cnt} =
      if including_carry_over <= @group_max_novel_cnt do
        {group_id, including_carry_over}
      else
        {group_id + 1, current_count}
      end

    [{group_id, target.remote_id}] ++ add_index(tail, group_id, group_novel_cnt)
  end

  defp add_index([], _, _), do: []

  defp fetch_and_apply_remote_data(writer_ids) do
    writer_ids
    |> Repo.Narou.find_by_userid([:n, :t, :ga, :gl, :u])
    |> format!()
    |> grouping_writer()
    |> tagging_with(load_writers(writer_ids))
    |> Enum.map(&create_notification_facts/1)
  end

  defp grouping_writer(fetch_facts) do
    fetch_facts |> Enum.group_by(&(&1.writer_remote_id))
  end

  def tagging_with(remote_writer_facts, local_writers) do
    get_remote_data = fn remote_id -> Map.get(remote_writer_facts, remote_id) end
    local_writers
    |> Enum.map(fn writer ->
      remote_data = get_remote_data.(writer.remote_id)

      cond do
        is_nil(remote_data) ->
          [tagged_fact(:writer_deleted, writer, nil)]
        true ->
          (Enum.map(writer.novels, &(&1.ncode)) ++ Enum.map(remote_data, &(&1.ncode)))
          |> Enum.uniq
          |> Enum.map(fn ncode ->
            get_novel = fn enumerable -> Enum.find(enumerable, &(&1.ncode == ncode)) end

            tagging_novel(get_novel.(writer.novels), get_novel.(remote_data))
          end)
      end
    end)
    |> Enum.flat_map(&(&1))
  end

  defp tagging_novel(local, remote) do
    cond do
      is_nil(remote) -> {:novel_deleted, local, nil}
      is_nil(local)  -> {:new_post_novel, nil, remote}
      true           ->
        local_episode_id = hd(local.episodes).episode_id

        tag = cond do
          local_episode_id <  remote.episode_id -> :novel_new_episode
          local_episode_id >  remote.episode_id -> :delete_novel_episode
          local_episode_id == remote.episode_id -> :novel_no_update
        end

        tagged_fact tag, local, remote
    end
  end

  defp tagged_fact(tag, local, remote), do: {tag, %{local: local, remote: remote}}

  defp load_writers(writer_ids) do
    Repo.Writers.find_by_ids_with_novels writer_ids
  end

  defp create_notification_facts(tagged_info), do: @child.start(tagged_info)

  defp format!({:ok, _, fetch_facts}) do
    fetch_facts
    |> Enum.map(fn data ->
      %{
        episode_id: data.general_all_no,
        remote_created_at: data.general_lastup,
        ncode: data.ncode,
        title: data.title,
        writer_remote_id: data.userid
      }
    end)
  end
#
##  defp fork_child(local, remote) when is_map(local) and is_map(remote) do
##    child_pid = child()
##    message =
##      cond do
##        local.episode_id >  remote.episode_id -> :novel_update
##        local.episode_id <  remote.episode_id -> :episode_delete
##        local.episode_id == remote.episode_id -> :novel_no_update
##      end
##
##    send child_pid, {message, %{local: local, remote: remote}}
##  end
##
##  defp fork_child(local, nil) do
##    child() |> send({:novel_deleted, %{local: local}})
##  end
##
##  defp child(), do: spawn(@child, :start, [])
#
#  def fork_child(local, remote) do
#    message =
#      cond do
#        is_nil(remote)                        -> :novel_deleted
#        local.episode_id <  remote.episode_id -> :novel_update
#        local.episode_id >  remote.episode_id -> :episode_delete
#        local.episode_id == remote.episode_id -> :novel_no_update
#      end
#
#    @child.start({message, %{local: local, remote: remote}})
#  end
end
