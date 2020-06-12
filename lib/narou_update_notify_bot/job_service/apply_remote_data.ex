defmodule NarouUpdateNotifyBot.JobService.ApplyRemoteData do
  alias NarouUpdateNotifyBot.Repo
  alias Repo.{
    Novels,
    NovelEpisodes,
    Writers,
    UsersCheckNovels,
    UsersCheckWriters,
    NotificationFacts
  }

  # TODO checkseet
  # - novel_new_episode ok
  # - delete_novel_episode ok
  # - new_post_novel ok
  # - delete_writer n
  #     FIXME
  # - delete_novel ok

  def start(arg) do
    case arg do
      {:novel_no_update, _}                   -> nil
      {type, %{local: local, remote: remote}} -> exec(type, local, remote)
      :ok
    end
  end

  def exec(type, local, remote) do
    IO.puts "---------------------"
    IO.inspect "@exec #{type}"
    IO.inspect local
    IO.inspect remote
    IO.puts "---------------------"
    update_local_data(type, local, remote)
    |> create_notification_data(type, local, remote)
  end

  def update_local_data(:novel_new_episode, local, remote) do
    Range.new(local.last_episode.episode_id + 1, remote.episode_id)
    |> Enum.map(&(NovelEpisodes.create(%{novel_id: local.id, episode_id: &1, remote_created_at: remote.remote_created_at})))
  end

  def update_local_data(:new_post_novel, local, remote) do
    writer = Writers.find_by_remote_id remote.writer_remote_id
    novel  = Novels.create_with_assoc_episode(
      %{ncode: remote.ncode, title: remote.title, writer_id: writer.id, remote_created_at: remote.remote_created_at, episode_id: 1}
    )
    %{writer: writer, novel: novel}
  end

  def update_local_data(:delete_novel_episode, local, remote) do
    Range.new(remote.episode_id + 1, local.last_episode.episode_id)
    |> Enum.map(&(NovelEpisodes.delete_by_novel(local.id, &1)))
  end

  def update_local_data(:delete_novel, local, _remote) do
    Novels.delete(local.id)
    UsersCheckNovels.unlink_all(local.id)
  end

  def update_local_data(:delete_writer, local, _remote) do
    Writers.delete(local.id)
    # FIXME
    # ここでアンリンクすると、通知データの作成対象が小説登録しているユーザのみになってしまう。
    # なので、分割しているメソッドをまとめるのがいいかも
    UsersCheckWriters.unlink_all(local.id)
  end


  def create_notification_data(result, :novel_new_episode, local,_) do
    UsersCheckNovels.all_users_who_have_registered_novel(local.id)
    |> Enum.each(fn user_id ->
      Enum.each(result, fn novel_episode ->
        NotificationFacts.create(
          %{type: :novel_new_episode, user_id: user_id, novel_episode_id: novel_episode.id}
        )
      end)
    end)
  end

  def create_notification_data(%{novel: novel, writer: writer}, :new_post_novel, _, remote) do
    UsersCheckWriters.all_users_who_have_registered_writer(writer.id)
    |> Enum.each(fn user_id ->
      NotificationFacts.create(
        %{type: :new_post_novel, user_id: user_id, novel_id: novel.id}
      )
    end)
  end

  def create_notification_data(result, :delete_novel, local,_) do
    Enum.each(result, &(NotificationFacts.create(
      %{type: :delete_novel, user_id: &1, novel_id: local.id}
    )))
  end

  def create_notification_data(result, :delete_writer, local, _) do
    UsersCheckWriters.all_users_who_have_registered_writer(:for_delete, local.id)
    |> Enum.each(&(NotificationFacts.create(
      %{type: :delete_writer, user_id: &1, writer_id: local.id}
    )))
  end

  def create_notification_data(results, :delete_novel_episode, _, _) do
    Enum.each(results, fn {:ok, result} ->
      Enum.each(UsersCheckNovels.all_users_who_have_registered_novel(result.novel_id),
        &(NotificationFacts.create(
        %{type: :delete_novel_episode, user_id: &1, novel_episode_id: result.id}
      ))
      )
    end)
  end
end
