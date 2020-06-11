defmodule NarouUpdateNotifyBot.Entity.Helper do
  require Logger
  def format_jpdate_to_utc(entity, key) do
    entity |> Map.update!(key, &iso8601_to_date_time/1)
  end

  def iso8601_to_date_time(str) do
    DateTime.from_iso8601(str <> "Z") |> elem(1) |> DateTime.add(3600 * -9)
  end
end
