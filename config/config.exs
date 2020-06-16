import Config

config :narou_update_notify_bot, NarouUpdateNotifyBot.Repo,
  database: "narou_update_notify_bot_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :narou_update_notify_bot, ecto_repos: [NarouUpdateNotifyBot.Repo]

config :line_bot,
  client_id:       System.get_env("LINE_CHANNEL_ID"),
  client_secret:   System.get_env("LINE_CHANNEL_SECRET"),
  skip_validation: false

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :narou_update_notify_bot, NarouUpdateNotifyBot.Scheduler,
  jobs: [
    {
      "* * * * *",
      fn -> NarouUpdateNotifyBot.JobService.FetchWritersAndCreateNotificationFacts.exec end
    },
    {
      "*/5 * * * *",
      fn -> NarouUpdateNotifyBot.JobService.NotificationToUser.exec end
    }
  ]

config :logger, level: if Mix.env == :test, do: :error, else: :debug
