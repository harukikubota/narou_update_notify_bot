defmodule NarouUpdateNotifyBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :narou_update_notify_bot,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [espec: :test],
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NarouUpdateNotifyBot.Application, []},
      env: [inquery_form_url: System.get_env("NAROU_BOT_INQUERY_FORM_URL")]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:narou, git: "https://github.com/harukikubota/narou.git", tag: "0.2.3"},
      {:line_bot, "~> 0.1.0"},
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:espec, "~> 1.8.2", only: :test},
      {:jason, "~> 1.0"},
      {:tzdata, "~> 1.0.3"},
      {:plug_cowboy, "~> 2.0"},
      {:logger_file_backend, "~> 0.0.10"}
    ]
  end

  defp aliases do
    [
      reset: ["ecto.drop", "ecto.create", "ecto.migrate", "run priv/repo/seed.exs"]
    ]
  end
end
