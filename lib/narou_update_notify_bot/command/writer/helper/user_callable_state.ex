defmodule NarouUpdateNotifyBot.Command.Writer.Helper.UserCallableState do
  alias NarouUpdateNotifyBot.Repo.UsersCheckWriters, as: C

  def judge(method, opt), do: if _judge(method, opt), do: {:ok}, else: {:error}

  defp _judge(:add, opt),    do: !C.registered?(opt.user_id, opt.writer_id)
  defp _judge(:delete, opt), do: C.registered?(opt.user_id, opt.writer_id)
end
