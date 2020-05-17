defmodule Mix.Tasks.DbReset do
  use Mix.Task

  @shortdoc "dbのリセット"
  def run(opt) do
    commands = [
      ["ecto.drop"],
      ["ecto.create"],
      ["ecto.migrate"],
      ["run", "priv/repo/seed.exs"]
    ]

    commands
    |> Enum.each(fn x ->
      IO.inspect "exec : mix #{inspect(x)}"
      System.cmd("mix", x)
    end)
  end
end
