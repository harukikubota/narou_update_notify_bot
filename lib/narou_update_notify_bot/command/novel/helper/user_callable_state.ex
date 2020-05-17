defmodule NarouUpdateNotifyBot.Command.Novel.Helper.UserCallableState do
  alias NarouUpdateNotifyBot.Repo.UsersCheckNovels, as: C
  alias NarouUpdateNotifyBot.Repo.UsersReadLaterNovels, as: R

  def judge(type, method, opt), do: if _judge(type, method, opt), do: {:ok}, else: {:error}

  defp _judge(_, :add, opt),                 do: !(C.registered?(opt.user_id, opt.novel_id) || R.registered?(opt.user_id, opt.novel_id))
  defp _judge(:update_notify, :delete, opt), do: C.registered?(opt.user_id, opt.novel_id)
  defp _judge(:read_later   , _, opt),       do: R.registered?(opt.user_id, opt.novel_id)
end
