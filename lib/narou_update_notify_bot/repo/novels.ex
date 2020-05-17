defmodule NarouUpdateNotifyBot.Repo.Novels do
  import Ecto.Query
  alias NarouUpdateNotifyBot.Entity.Novel
  alias NarouUpdateNotifyBot.Repo

  @spec all() :: list(map) | []
  def all() do
    Repo.all(Novel)
  end

  @spec find(integer) :: map | nil
  def find(id) do
    Repo.get(Novel, id)
  end

  def find_by_ncode(ncode) do
    Repo.get_by(Novel, ncode: ncode)
  end

  def find_or_create_by(ncode) do
    record = find_by_ncode(ncode)
    case is_nil(record) do
      false -> {:ok, record}
      true ->
        [:general_all_no, :userid, :title]
        case Repo.Narou.find_by_ncode(ncode, [:ga, :u, :t, :gl]) do
          {:ok, %{general_all_no: episode_count, title: title, userid: remote_writer_id, general_lastup: remote_updated_at}} ->
            novel_ch = _changeset(%{episode_count: episode_count, title: title, ncode: ncode, remote_updated_at: remote_updated_at})

            if novel_ch.valid? do
              {:ok, writer} = Repo.Writers.find_or_create_by(remote_writer_id)
              novel = Ecto.build_assoc(writer, :novels, novel_ch.changes) |> Repo.insert!
              {:ok, novel}
            end

          {:no_data} -> {:no_data}
          {_, _}     -> {:error}
        end
    end
  end

  defp _changeset(attr) do
    Novel.changeset(%Novel{}, attr)
  end
end
