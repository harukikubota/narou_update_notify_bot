defmodule NarouUpdateNotifyBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :narou_update_notify_bot,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NarouUpdateNotifyBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:narou, git: "https://github.com/harukikubota/narou"},
      {:line_bot, "~> 0.1.0"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:espec, "~> 1.8.2", only: :test},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
