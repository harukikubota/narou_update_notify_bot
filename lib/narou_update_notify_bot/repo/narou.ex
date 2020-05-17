defmodule NarouUpdateNotifyBot.Repo.Narou do
  use Narou.Query

  @doc """
  小説を一件検索する。
  デフォルト引数：小説のエピソード数、ユーザID、タイトルを取得する。
  """
  def find_by_ncode(ncode, cols \\ [:general_all_no, :userid, :title])
      when is_binary(ncode)
    do
    case _init() |> select(cols) |> where(ncode: ncode) |> _exec! do
      {:ok, 1, [result]} -> {:ok, result}
      {:no_data}         -> {:no_data}
    end
  end

  @doc """
  小説の複数件検索する。
  デフォルト引数：小説のエピソード数を取得する。
  """
  @spec find_by_ncodes(list(atom), list(atom)) :: term
  def find_by_ncodes(ncodes, cols \\ [:ncode, :general_all_no])
      when is_list(ncodes)
    do
    _init() |> select(cols) |> where(ncode: ncodes) |> _exec!
  end

  @doc """
  ユーザを一件検索する。
  デフォルト引数：ユーザID、小説投稿数、名前を取得する。
  """
  def find_by_writer_id(writer_id, cols \\ [:novel_cnt, :name]) do
    case _init(:user) |> select(cols) |> where(userid: writer_id) |> _exec! do
      {:ok, _, [result]} -> result
      {:no_data} -> {:no_data}
    end
  end

  defp _init(type \\ :novel) do
    Narou.init %{type: type}
  end

  defp _exec!(map) do
    map |> Narou.run! |> Narou.format()
  end
end
