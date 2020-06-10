defmodule NarouUpdateNotifyBot.Repo.Util do
  alias NarouUpdateNotifyBot.Repo

  def exec_delete(record) do
    record
    |> Ecto.Changeset.change(%{remote_deleted: true, remote_deleted_at: now()})
    |> Repo.update()
  end

  def exec_delete_all(querable) do
    querable
    |> Repo.update_all(set: [remote_deleted: true, remote_deleted_at: now()])
  end

  def now(), do: DateTime.utc_now() |> DateTime.truncate(:second)
end

