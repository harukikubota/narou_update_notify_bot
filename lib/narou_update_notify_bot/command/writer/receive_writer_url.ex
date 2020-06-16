defmodule NarouUpdateNotifyBot.Command.Writer.ReceiveWriterUrl do
  use NarouUpdateNotifyBot.Command
  alias NarouUpdateNotifyBot.Repo.{Writers, Users, UsersCheckWriters}

  def call(param) do
    case Writers.find_or_create_by(param.writer_id) do
      {:no_data}    -> render_with_send(:no_data, nil, param.key)
      {:ok, writer} ->
        user = Users.find_by_line_id(param.user_id)

        (if UsersCheckWriters.registered?(user.id, writer.id), do: :registered, else: :no_register)
        |> render_with_send(%{writer: writer}, param.key)
    end
  end
end
