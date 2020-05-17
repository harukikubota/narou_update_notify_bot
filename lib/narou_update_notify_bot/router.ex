defmodule NarouUpdateNotifyBot.Router do
  use Plug.Router

  plug :match
  plug :dispatch
  forward "/bot", to: LineBot.Webhook, callback: NarouUpdateNotifyBot.Callback
end