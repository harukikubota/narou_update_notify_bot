defmodule NarouUpdateNotifyBot.Repo.UsersCheckWriters do
  alias NarouUpdateNotifyBot.Repo
  alias NarouUpdateNotifyBot.Entity.UserCheckWriter
  import Ecto.Query

  def registered?(user_id, writer_id) do
    !!(from(UserCheckWriter, where: [user_id: ^user_id, writer_id: ^writer_id]) |> first() |> Repo.one())
  end

  def link_to(user_id, writer_id) do
    UserCheckWriter.changeset(%UserCheckWriter{}, %{user_id: user_id, writer_id: writer_id}) |> Repo.insert!
  end

  def unlink_to(user_id, writer_id) do
    from(UserCheckWriter, where: [user_id: ^user_id, writer_id: ^writer_id]) |> Repo.delete_all
  end
end
