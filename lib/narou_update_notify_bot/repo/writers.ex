defmodule NarouUpdateNotifyBot.Repo.Writers do
  alias NarouUpdateNotifyBot.Repo
  alias NarouUpdateNotifyBot.Entity.Writer

  def find_or_create_by(remote_id) do
    record = Repo.get_by(Writer, remote_id: remote_id)
    case is_nil(record) do
      false -> {:ok, record}
      true ->
        case Repo.Narou.find_by_writer_id(remote_id) do
          %{novel_cnt: novel_count, name: name} ->
            {:ok, _changeset(%{novel_count: novel_count, name: name, remote_id: remote_id}) |> Repo.insert!}
          {_, v} -> {:error}
        end
    end
  end

  def find(id) do
    Repo.get(Writer, id)
  end

  defp _changeset(attr) do
    Writer.changeset(%Writer{}, attr)
  end
end
