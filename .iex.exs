import Ecto.Query
alias NarouUpdateNotifyBot.Repo
alias Repo.{
  Users,
  Novels,
  NovelEpisodes,
  Writers,
  UsersCheckWriters,
  UsersCheckNovels,
  NotificationFacts
}
alias NarouUpdateNotifyBot.Entity.{
  User,
  Novel,
  NovelEpisode,
  Writer,
  UserCheckWriter,
  UserCheckNovel,
  NotificationInfo
}
