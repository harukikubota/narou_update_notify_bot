defmodule NarouUpdateNotifyBot.Command.MessageServer do
  use Agent

  def start_link(mod_name, token) do
    key = gen_key(mod_name, token)
    {:ok, pid} = Agent.start_link(fn -> %{messages: [], token: token} end, name: key)
    {:ok, pid, key}
  end

  def get_messages(key),    do: Agent.get(key, &(Map.get(&1, :messages)))
  def get_reply_token(key), do: Agent.get(key, &(Map.get(&1, :token)))

  def push(messages, key) do
    Agent.update(key, &(Map.replace!(&1, :messages, Map.get(&1, :messages) ++ List.wrap(messages))))
  end

  defp gen_key(mod_name, token) do
    :crypto.hash(:sha256, to_string(mod_name) <> token)
    |> Base.encode16(case: :lower)
    |> String.to_atom
  end

  def stop(pid), do: Agent.stop(pid)
end
