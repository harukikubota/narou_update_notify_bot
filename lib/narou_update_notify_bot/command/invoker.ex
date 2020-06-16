defmodule NarouUpdateNotifyBot.Command.Invoker do
@moduledoc """
  指定したコマンドを実行する。
"""

  def invoke(mod, func_name, param),          do: _invoke(env(), mod, func_name, param)
  defp _invoke(:test, mod, func_name, param), do: [mod, func_name, param]
  defp _invoke(_, mod, func_name, param) do
    {:ok, pid, key} = apply(mod, :init, [param.reply_token])

    apply(mod, func_name, [Map.merge(param, %{key: key})])

    apply(mod, :close, [pid])
  end
  defp env(), do: Mix.env
end
