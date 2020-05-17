defmodule NarouUpdateNotifyBot.Repo.Users do
  alias NarouUpdateNotifyBot.Repo
  alias NarouUpdateNotifyBot.Entity.User

  def find_or_create_by(line_id) do
    user = find_by_line_id(line_id)
    unless is_nil(user) do
      {:created, user}
    else
      {:ok, new_user(line_id)}
    end
  end

  def new_user(line_id), do: User.changeset(%User{}, %{line_id: line_id}) |> Repo.insert!
  def find_by_line_id(line_id), do: Repo.get_by(User, line_id: line_id)
  def enable_to(user),  do: User.changeset(user, %{enabled: true}) |> Repo.update!
  def disable_to(user), do: User.changeset(user, %{enabled: false}) |> Repo.update!
end
