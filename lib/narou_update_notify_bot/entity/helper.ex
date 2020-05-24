defmodule NarouUpdateNotifyBot.Entity.Helper do
  def format_jpdate_to_utc(entity, key) do
    entity
    |> Map.update!(key, &(NaiveDateTime.from_iso8601(&1) |> elem(1) |> NaiveDateTime.add(3600 * -9)))
  end
end
