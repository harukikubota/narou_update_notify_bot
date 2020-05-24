defmodule NarouUpdateNotifyBot.Template.Writer.Helper do
  def make_writer_mypage_url(writer_id), do: "https://mypage.syosetu.com/" <> to_string(writer_id)
end
