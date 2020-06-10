defmodule NarouUpdateNotifyBot.Repo.Writers do
  alias NarouUpdateNotifyBot.Repo
  alias Repo.{Util, Novels, NovelEpisodes}
  alias NarouUpdateNotifyBot.Entity.{
    Writer,
    Novel,
    NovelEpisode,
    UserCheckNovel
  }
  import Ecto.Query
  alias NarouUpdateNotifyBot.JobService.RegisterWriterPostNovels, as: Job
  require Logger

  def find_or_create_by(remote_id) do
    record = find_by_remote_id(remote_id)
    case is_nil(record) do
      false -> {:ok, record}
      true ->
        case Repo.Narou.find_by_writer_id(remote_id) do
          %{novel_cnt: novel_count, name: name} ->
            writer = create(%{novel_count: novel_count, name: name, remote_id: remote_id})

            spawn(Job, :exec, [writer.id])

            {:ok, writer}
          {_, v} -> {:error, v}
        end
    end
  end

  def find(id),              do: Repo.get(Writer, id)
  def find_by_remote_id(id), do: Repo.get_by(Writer, remote_id: id)

  def writer_detail(user_id), do: writer_detail_query(user_id) |> Repo.all
  def writer_detail(user_id, writer_id) do
    writer_detail_query(user_id)
    |> where([w,n,uc], w.id == ^writer_id)
    |> first()
    |> Repo.one
  end

  def writer_detail_query(user_id) do
    novels_query =
      from  n  in Novel,
      join: uc in UserCheckNovel, on: n.id == uc.novel_id,
      where: uc.user_id == ^user_id,
      select: %{id: n.id, title: n.title, type: uc.type}

    from w in Writer,
      join: u in assoc(w, :users),
      where: u.id == ^user_id,
      preload: [novels: ^novels_query]
  end

  def delete(id) do
    writer = Repo.get(Writer, id)
    Util.exec_delete(writer)

    from(n in Novel, where: n.writer_id == ^id)
    |> Util.exec_delete_all()

    writer
  end

  def select_for_register_post_novels(id) do
    from(
      w in Writer,
      where: w.id == ^id,
      lock: "FOR UPDATE"
    )
    |> first()
    |> Repo.one
    |> Repo.preload(:novels)
  end

  def create(attr) do
    %Writer{}
    |> Map.merge(attr)
    |> Repo.insert!
  end

  def records_to_fetch() do
    from(
      w in Writer,
      where: w.remote_deleted == false and w.id == 5,
      order_by: w.remote_id,
      select: %{remote_id: w.remote_id, novel_count: w.novel_count}
    )
    |> Repo.all
  end

  def find_by_ids_with_novels(remote_ids) do
    from(
      w in Writer,
      join: n in assoc(w, :novels),
      on: w.id == n.writer_id,
      where: w.remote_id in ^remote_ids and n.remote_deleted == false,
      order_by: w.remote_id,
      preload: [novels: {n, episodes: ^NovelEpisodes.novel_last_episodes_query}]
    )
    |> Repo.all()
  end
end
