defmodule NarouUpdateNotifyBot.Repo.UsersCheckWriters do
  alias NarouUpdateNotifyBot.Repo
  alias NarouUpdateNotifyBot.Entity.{User, UserCheckWriter}
  import Ecto.Query

  def registered?(user_id, writer_id) do
    !!(from(UserCheckWriter, where: [user_id: ^user_id, writer_id: ^writer_id]) |> first() |> Repo.one())
  end

  def user_register_count(user_id) do
    Repo.one from uc in UserCheckWriter, where: uc.user_id == ^user_id, select: count()
  end

  def link_to(user_id, writer_id) do
    UserCheckWriter.changeset(%UserCheckWriter{}, %{user_id: user_id, writer_id: writer_id}) |> Repo.insert!
  end

  def unlink_to(user_id, writer_id) do
    from(UserCheckWriter, where: [user_id: ^user_id, writer_id: ^writer_id]) |> Repo.delete_all
  end

  def unlink_all(writer_id) do
    users = all_users_who_have_registered_writer(writer_id)
    Enum.each(users, &(unlink_to(&1, writer_id)))
    users
  end

  def all_users_who_have_registered_writer(writer_id) do
    from(
      uc in UserCheckWriter,
      join: u in User, on: uc.user_id == u.id,
      where: uc.writer_id == ^writer_id and u.enabled == true,
      select: u.id
    )
    |> Repo.all
  end
end
