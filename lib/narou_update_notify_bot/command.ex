defmodule NarouUpdateNotifyBot.Command do
  defmacro __using__(_) do
    quote do
      alias LineBot.Message
      alias NarouUpdateNotifyBot.Command.MessageServer, as: MS
      alias NarouUpdateNotifyBot.Command.Helper

      def init(token),          do: {:ok, pid, key} = MS.start_link(__MODULE__, token)
      def template(),           do: NarouUpdateNotifyBot.Command.template_name(__MODULE__)
      def messages(key),        do: MS.get_messages(key)
      def reply_token(key),     do: MS.get_reply_token(key)
      def render(id, dao, key), do: template().render(id, dao) |> MS.push(key)
      def send(key),            do: LineBot.send_reply(reply_token(key), messages(key))
      def render_with_send(id, dao, key) do
        render(id, dao, key)
        send(key)
      end
      def close(pid), do: MS.stop(pid)
    end
  end

  def template_name(module) do
    module
    |> to_string
    |> String.split(".")
    |> List.replace_at(2, "Template")
    |> Enum.join(".")
    |> String.to_atom
  end
end
