defmodule NarouUpdateNotifyBot.Callback do
  use LineBot

  @invoker NarouUpdateNotifyBot.Command.Invoker

  def handle_message(%{type: "text", text: message}, info) do
    with %{"ncode" => ncode, "episode_id" => episode_id} <- Regex.named_captures(Util.Constant.novel_regex(), message)
    do
      invoke([:novel, :receive_novel_url], Map.merge(info, %{ncode: ncode, episode_id: episode_id}))
    else
      _ ->
        with %{"writer_id" => writer_id}
          <- Regex.named_captures(Util.Constant.writer_regex(), message)
        do
          invoke([:writer, :receive_writer_url], Map.merge(info, %{writer_id: writer_id}))
        else
          _ -> default(info)
        end
    end
  end

  def handle_follow(info),   do: invoke([:user, :follow],   info)
  def handle_unfollow(info), do: invoke([:user, :unfollow], info)

  def handle_postback(data, info) do
    {%{action: action}, data} = data |> Map.split([:action])

    action
    |> String.split("/")
    |> Enum.map(&(String.to_atom(&1)))
    |> invoke(Map.merge(info, %{data: data}))
  end

  defp default(info), do: invoke(:default, info)

  @spec invoke(any, map) :: {:ok, any} | {:error, any}
  defp invoke(mod_symbols, param) do
    to_mod(mod_symbols) |> @invoker.invoke(:call, param)
  end

  defp to_mod(mod_symbols) do
    sub = List.wrap(mod_symbols)
      |> Enum.map(&(Macro.camelize(to_string(&1))))
      |> Enum.join(".")
    Module.concat(NarouUpdateNotifyBot.Command, sub)
  end
end
