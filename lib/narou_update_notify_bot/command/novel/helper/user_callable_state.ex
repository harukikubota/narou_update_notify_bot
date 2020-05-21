defmodule NarouUpdateNotifyBot.Command.Novel.Helper.UserCallableState do
  alias NarouUpdateNotifyBot.Repo.UsersCheckNovels, as: C

  def judge(type, method, opt), do: if _judge(type, method, opt), do: {:ok}, else: {:error}

  defp _judge(_, :add, opt),          do: !(C.registered?(opt.user_id, opt.novel_id, :update_notify) || C.registered?(opt.user_id, opt.novel_id, :read_later))
  defp _judge(type, :delete, opt),    do: C.registered?(opt.user_id, opt.novel_id, type)
  defp _judge(:read_later  , _, opt), do: C.registered?(opt.user_id, opt.novel_id, :read_later)
end
