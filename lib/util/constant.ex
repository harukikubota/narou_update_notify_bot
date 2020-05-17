defmodule Util.Constant do
  def novel_domain(), do: "https://ncode.syosetu.com"
  def novel_domain_reg_str(), do: String.replace(novel_domain, "s", "[s]?", global: false)

  def writer_domain(), do: "https://mypage.syosetu.com"
  def writer_domain_reg_str(), do: String.replace(writer_domain, "s", "[s]?", global: false)

  def novel_regex() do
    Regex.compile(
      "^" <>
      novel_domain_reg_str() <>
      "/(?<ncode>" <>
      "n" <>
      String.slice(Narou.Util.ncode_format.source, 5..-3) <>
      ")(\/(?<episode_id>[\\d]+))?.*$"
    ) |> elem(1)
  end

  def writer_regex() do
    Regex.compile(
      "^" <>
      writer_domain_reg_str() <>
      "/(?<writer_id>[\\d]+)" <>
      ".*$"
    ) |> elem(1)
  end
end