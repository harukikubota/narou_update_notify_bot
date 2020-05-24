defmodule NarouUpdateNotifyBot.Repo.Writers do
  alias NarouUpdateNotifyBot.Repo
  alias NarouUpdateNotifyBot.Entity.{
    Writer,
    Novel,
    UserCheckNovel
  }
  import Ecto.Query

  def find_or_create_by(remote_id) do
    record = Repo.get_by(Writer, remote_id: remote_id)
    case is_nil(record) do
      false -> {:ok, record}
      true ->
        case Repo.Narou.find_by_writer_id(remote_id) do
          %{novel_cnt: novel_count, name: name} ->
            {:ok, _changeset(%{novel_count: novel_count, name: name, remote_id: remote_id}) |> Repo.insert!}
          {_, v} -> {:error, v}
        end
    end
  end

  def find(id) do
    Repo.get(Writer, id)
  end
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

  defp _changeset(attr) do
    Writer.changeset(%Writer{}, attr)
  end
end
