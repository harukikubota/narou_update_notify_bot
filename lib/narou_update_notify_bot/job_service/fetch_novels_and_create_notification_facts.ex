defmodule NarouUpdateNotifyBot.JobService.FetchNovelsAndCreateNotificationFacts do
  alias NarouUpdateNotifyBot.Repo
  alias NarouUpdateNotifyBot.Entity.Helper

  @child NarouUpdateNotifyBot.JobService.ApplyRemoteData

  def exec() do
    novels = targets()
    ncodes = novels |> Enum.map(&(&1.ncode))

    {:ok, _, results} = Repo.Narou.find_by_ncodes(ncodes, [:n, :u, :gl, :ga])
    results = results |> Enum.map(&format_key/1)

    novels
    |> Enum.map(&(fork_child(&1, remote_corresponding_record(results, &1.ncode))))
    IO.inspect "exit"
    nil
  end

  defp targets(), do: Repo.Novels.records_for_fetch()

  defp remote_corresponding_record(records, ncode) do
    Enum.find(records, fn %{ncode: l_ncode} -> l_ncode == ncode end)
  end

#  defp fork_child(local, remote) when is_map(local) and is_map(remote) do
#    child_pid = child()
#    message =
#      cond do
#        local.episode_id >  remote.episode_id -> :novel_update
#        local.episode_id <  remote.episode_id -> :episode_delete
#        local.episode_id == remote.episode_id -> :novel_no_update
#      end
#
#    send child_pid, {message, %{local: local, remote: remote}}
#  end
#
#  defp fork_child(local, nil) do
#    child() |> send({:novel_deleted, %{local: local}})
#  end
#
#  defp child(), do: spawn(@child, :start, [])

  def fork_child(local, remote) do
    message =
      cond do
        is_nil(remote)                        -> :novel_deleted
        local.episode_id <  remote.episode_id -> :novel_update
        local.episode_id >  remote.episode_id -> :episode_delete
        local.episode_id == remote.episode_id -> :novel_no_update
      end

    @child.start({message, %{local: local, remote: remote}})
  end

  defp format_key(%{general_all_no: ga, general_lastup: gl, ncode: ncode, userid: writer_id}) do
    %{
      episode_id: ga,
      created: Helper.format_jpdate_to_utc(%{a: gl}, :a) |> Map.get(:a),
      ncode: ncode,
      writer_id: writer_id
    }
  end
end
