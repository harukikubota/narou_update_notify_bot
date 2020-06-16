defmodule NarouUpdateNotifyBot.Command.Default do
  use NarouUpdateNotifyBot.Command

  def call(param) do
    render_with_send(:unsupported, nil, param.key)
  end
end
