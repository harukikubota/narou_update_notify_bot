#mix ecto.drop && mix ecto.create && mix ecto.migrate && mi
defmodule NarouUpdateNotifyBot.Seed do
  import Ecto.Query
  alias NarouUpdateNotifyBot.Repo
  alias Repo.{
    Users,
    Novels,
    Writers,
    UsersCheckNovels,
    UsersCheckWriters,
    NovelEpisodes,
    NotificationFacts
  }
  alias NarouUpdateNotifyBot.Entity.{
    NovelEpisode
  }

  def main do
    setup
    create_sfo_histries_date(1)
    delete_novel_leatest_episode(1)
    create_dummy_and_link(1)
  end

  def create_many_writers do
    remote_ids =
      [
        161807,
        235132,
        311735,
        430311,
        474038,
        552120,
        491287,
        288399,
        151239,
        631969,
        960535,
        224211,
        168215,
        313910,
        242986,
        509642
      ]

    remote_ids |> Enum.each(&Writers.find_or_create_by/1)
  end

  def setup do
    user = Users.new_user "Uc043bb4602f875df9d19e266c67d0f57"
    tuser = Users.new_user "hogehoge"

    {:ok, sfo} = Novels.find_or_create_by("n6169dz")
    {:ok, rzr} = Novels.find_or_create_by("n2267be")
    {:ok, tsr} = Novels.find_or_create_by("n6316bn")
    {:ok, mks} = Novels.find_or_create_by("n6715cb")
    {:ok, ubr} = Novels.find_or_create_by("n9016cm")

    UsersCheckNovels.link_to(user.id, sfo.id)
    UsersCheckNovels.link_to(tuser.id, sfo.id)
    UsersCheckNovels.link_to(user.id, rzr.id, 1)
    UsersCheckNovels.link_to(tuser.id, tsr.id)

    UsersCheckWriters.link_to(user.id, sfo.writer_id)
    UsersCheckWriters.link_to(user.id, rzr.writer_id)
    UsersCheckWriters.link_to(tuser.id, tsr.writer_id)
  end

  def create_sfo_histries_date(novel_id) do
    sfo_episode_histries =
      [
        {20,"05","13","11","01"},
        {20,"05","17","18","56"},
        {20,"05","25","13","25"},
        {20,"05","27","19","00"},
        {20,"05","27","19","56"},
        {20,"05","27","21","03"},
        {20,"05","29","16","50"},
        {20,"06","01","14","49"},
        {20,"06","03","14","19"},
        {20,"06","05","20","51"},
      ]

    sfo_episode_histries
    |> Enum.map(fn {y, m, d, h, mi} ->
      DateTime.from_iso8601("#{2000 + y}-#{m}-#{d} #{h}:#{mi}:00Z")
      |> elem(1)
      |> DateTime.add(3600 * -9)
    end)
    |> Enum.with_index(706)
    |> Enum.each(fn {created, episode_id} ->
      NovelEpisodes.create(%{novel_id: novel_id, episode_id: episode_id, remote_created_at: created})
    end)
  end

  def delete_novel_leatest_episode(novel_id) do
    from(ne in NovelEpisode, where: ne.novel_id == ^novel_id, order_by: [desc: ne.episode_id], limit: 1) |> Repo.one |> Repo.delete
  end

  def create_dummy_and_link(user_id, attr \\ %{}) do
    dummy_novel = Novels.create_for_new_novel(
      %{ncode: "n9999aaa", title: "dummy", writer_id: 1, remote_created_at: "2020-05-13 02:01:00"} |> Map.merge(attr)
    )

    UsersCheckNovels.link_to(user_id, dummy_novel.id)
  end

  def create_dummy_notification_facts(user_id) do
    [
      %{type: :novel_new_episode,    novel_episode_id: 1},
      %{type: :new_post_novel,       novel_id:         1},
      %{type: :delete_novel,         novel_id:         1},
      %{type: :delete_novel_episode, novel_episode_id: 1},
      %{type: :delete_writer,        writer_id:        1}
    ]
    |> Map.merge(%{user_id: user_id})
    |> Enum.each(&NotificationFacts.create/1)
  end
end

NarouUpdateNotifyBot.Seed.main()
:timer.sleep(10000)
