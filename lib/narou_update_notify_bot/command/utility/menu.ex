defmodule NarouUpdateNotifyBot.Command.Utility.Menu do
  use NarouUpdateNotifyBot.Command

  def call(param) do
    IO.inspect param.name
  end
end
