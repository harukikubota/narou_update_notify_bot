defmodule NarouUpdateNotifyBot.JobService.NotificationToUser do
  alias NarouUpdateNotifyBot.Repo.{
    NotificationFacts
  }
  alias NarouUpdateNotifyBot.Template.JobService.Notificate_data, as: Template
  require Logger

  def exec do
    update_records_not_to_be_notified()

    notification_facts()
    |> update_all_to_job_touch
    |> allocate_to_each_user
    |> Enum.each(&notification_to_user/1)
  end

  defp update_records_not_to_be_notified do
    NotificationFacts.change_notification_off_novel_update_record_to_unread()
  end

  defp notification_facts, do: NotificationFacts.inserted_records()

  defp update_all_to_job_touch(records) do
    NotificationFacts.change_status_all(records, :job_touch)
    records
  end

  defp allocate_to_each_user(records) do
    Enum.group_by(records, &(&1.user_id))
    |> Enum.map(fn {_, v} -> v end)
  end

  def notification_to_user(records) do
    user_id = hd(records).user.line_id
    Logger.info user_id
    case LineBot.send_push(user_id, render_message(records)) do
      {:ok, _}    -> NotificationFacts.change_status_all(records, :notificated)
      {_, reason} -> NotificationFacts.change_status_all(records, :error, reason)
    end
  end

  defp render_message(records), do: Template.render(:ok, records)
end
