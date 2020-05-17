defmodule NarouUpdateNotifyBot.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      NarouUpdateNotifyBot.Repo,
      Plug.Cowboy.child_spec(scheme: :http, plug: NarouUpdateNotifyBot.Router, options: [port: 4001])
    ]

    opts = [strategy: :one_for_one, name: NarouUpdateNotifyBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
