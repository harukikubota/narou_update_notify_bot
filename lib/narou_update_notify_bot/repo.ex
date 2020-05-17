defmodule NarouUpdateNotifyBot.Repo do
  use Ecto.Repo,
    otp_app: :narou_update_notify_bot,
    adapter: Ecto.Adapters.Postgres
end
