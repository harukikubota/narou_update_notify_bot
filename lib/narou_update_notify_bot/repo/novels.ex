defmodule NarouUpdateNotifyBot.Repo.Novels do
  import Ecto.Query
  alias NarouUpdateNotifyBot.Repo
  alias Repo.NovelEpisodes
  alias NarouUpdateNotifyBot.Entity.{
    Novel,
    Writer,
    UserCheckNovel,
    Helper
  }

  @spec all() :: list(map) | []
  def all() do
    Repo.all(Novel)
  end

  @spec find(integer) :: map | nil
  def find(id) do
    Repo.get(Novel, id)
  end

  def novel_detail(type, user_id), do: _novel_detail(type, user_id) |> Repo.all
  def novel_detail(type, user_id, novel_id) do
    _novel_detail(type, user_id)
    |> where([n,_,_,_], n.id == ^novel_id)
    |> first()
    |> Repo.one
  end

  defp _novel_detail(type, user_id) do
    novel_detail_query(type, user_id)
    |> novel_detail_additional_columns(type)
  end

  defp novel_detail_query(type, user_id) do
    from n in Novel,
      join: uc in UserCheckNovel, on: n.id == uc.novel_id,
      join: w  in Writer        , on: n.writer_id == w.id,
      join: ne in subquery(NovelEpisodes.novel_last_episodes_query),
      on: ne.novel_id == n.id,
      where: uc.type    == ^type,
      where: uc.user_id == ^user_id,
      select: %{
        id: n.id, ncode: n.ncode, title: n.title,
        writer_name: w.name, writer_id: n.writer_id,
        episode_id: ne.episode_id, remote_created_at: ne.remote_created_at
      }
  end

  defp novel_detail_additional_columns(q, "update_notify"), do: q |> select_merge([_,uc,_,_], %{do_notify: uc.do_notify})
  defp novel_detail_additional_columns(q, "read_later"),    do: q |> select_merge([_,uc,_,_], %{restart_episode_id: uc.restart_episode_id, restart_index_updated_at: uc.updated_at})

  def find_by_ncode(ncode) do
    Repo.get_by(Novel, ncode: ncode)
  end

  def find_or_create_by(ncode) do
    record = find_by_ncode(ncode)
    case is_nil(record) do
      false -> {:ok, record}
      true ->
        case Repo.Narou.find_by_ncode(ncode, [:ga, :u, :t, :gl]) do
          {:ok, %{general_all_no: episode_id, title: title, userid: remote_writer_id, general_lastup: general_lastup}} ->
            novel = create(%{ncode: ncode, title: title})

            Ecto.build_assoc(novel, :episodes, %{episode_id: episode_id, remote_created_at: general_lastup})
            |> Helper.format_jpdate_to_utc(:remote_created_at)
            |> Repo.insert!

            {:ok, writer} = Repo.Writers.find_or_create_by(remote_writer_id)

            Ecto.Changeset.change(novel, %{writer_id: writer.id}) |> Repo.update

          {:no_data} -> {:no_data}
          {_, _}     -> {:error}
        end
    end
  end

  def create(%{ncode: ncode, title: title}) do
    %Novel{} |> Map.merge(%{title: title, ncode: ncode}) |> Repo.insert!
  end
end
