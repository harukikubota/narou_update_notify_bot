defmodule NarouUpdateNotifyBot.Repo.Novels do
  import Ecto.Query
  alias NarouUpdateNotifyBot.Repo
  alias Repo.{Util, NovelEpisodes}
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
    from(
      n in Novel,
      join: w  in Writer , on: n.writer_id == w.id,
      join: ne in subquery(NovelEpisodes.novel_last_episodes_query),
      on: ne.novel_id == n.id,
      where: n.ncode == ^ncode and n.remote_deleted == false,
      select: %{
        id: n.id, ncode: n.ncode, title: n.title,
        writer_name: w.name, writer_id: n.writer_id,
        episode_id: ne.episode_id, remote_created_at: ne.remote_created_at
      }
    )
    |> first()
    |> Repo.one
  end

  def find_or_create_by(ncode) do
    record = find_by_ncode(ncode)
    case is_nil(record) do
      false -> {:ok, record}
      true ->
        case Repo.Narou.find_by_ncode(ncode, [:ga, :u, :t, :gl]) do
          {:ok, %{general_all_no: episode_id, title: title, userid: remote_writer_id, general_lastup: general_lastup}} ->
            {:ok, writer} = Repo.Writers.find_or_create_by(remote_writer_id)

            novel = create(%{ncode: ncode, title: title, writer_id: writer.id})

            %{novel_id: novel.id, episode_id: episode_id, remote_created_at: general_lastup}
            |> Helper.format_jpdate_to_utc(:remote_created_at)
            |> NovelEpisodes.create()

            {:ok, find_by_ncode(novel.ncode)}

          {:no_data} -> {:no_data}
          {_, _}     -> {:error}
        end
    end
  end

  def create(param) do
    %Novel{} |> Map.merge(param) |> Repo.insert!
  end

  def create_with_assoc_episode(%{ncode: ncode, title: title, writer_id: writer_id, episode_id: episode_id, remote_created_at: remote_created_at}) do
    novel = create(%{ncode: ncode, title: title, writer_id: writer_id})

    %{novel_id: novel.id, episode_id: episode_id, remote_created_at: remote_created_at}
    |> Helper.format_jpdate_to_utc(:remote_created_at)
    |> NovelEpisodes.create()

    novel
  end

  def create_for_new_novel(%{ncode: ncode, title: title, writer_id: writer_id, remote_created_at: remote_created_at}) do
    novel = create(%{ncode: ncode, title: title, writer_id: writer_id})

    %{novel_id: novel.id, episode_id: 1, remote_created_at: remote_created_at}
    |> Helper.format_jpdate_to_utc(:remote_created_at)
    |> NovelEpisodes.create()

    novel
  end

  def delete(id) do
    find(id) |> Util.exec_delete()
  end

  def records_for_fetch() do
    from(
      n in Novel,
      join: ne in subquery(NovelEpisodes.novel_last_episodes_query),
      on: ne.novel_id == n.id,
      where: n.remote_deleted == false,
      order_by: [desc: n.ncode],
      select: %{
        id: n.id, ncode: n.ncode,
        episode_id: ne.episode_id
      }
    )
    |> Repo.all
  end
end
