defmodule NarouUpdateNotifyBot.Command.Utility.Separator do
  use NarouUpdateNotifyBot.Command

  def call(param), do: render_with_send(:ok, "-", param.key)
end
