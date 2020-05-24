defmodule NarouUpdateNotifyBot.Command.Novel.ShowUpdateHistory do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.{Novels, NovelEpisodes}

  def call(param) do
    novel = Novels.find(param.data.novel_id)
    history = NovelEpisodes.leatest_update_history(param.data.novel_id)
    render_with_send(:ok, %{novel: novel, history: history}, param.key)
  end
end
