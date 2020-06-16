defmodule NarouUpdateNotifyBot.RichMenu do
  alias NarouUpdateNotifyBot.Repo.RichMenus, as: Repo

  @bin_path File.cwd! <> "/lib/bin/"
  @image_path "priv/image"
  @token Application.get_env(:line_bot, :client_id)

  defmacro __using__(_) do
    quote do
      alias LineBot.Message.Action
      alias NarouUpdateNotifyBot.Template.Helper, as: H

      def areas(opt) do
        [x: x, y: y, w: width, h: height, action: action] = opt

        %{
          "action" => action,
          "bounds" => %{"x" => x, "y" => y, "width" => width, "height" => height}
        }
      end
    end
  end

  def main do
    reset()
    targets()
    |> Enum.map(&(&1.data()))
    |> Enum.map(&(%{name: &1.name, data: &1}))
    |> tap(&link_to_remote_and_local/1)
    |> List.first()
    |> set_default_menu()
  end

  def reset() do
    Enum.map(Repo.all, &(&1.remote_id))
    |> Enum.each(&remote_delete/1)
    db_drop()
  end

  def db_drop(), do: Repo.delete_all!()
  def remote_delete(rich_menu_id) do
    System.cmd(@bin_path <> "delete_lich_menu", [rich_menu_id, @token])
  end

  def link_to_remote_and_local(%{name: name, data: data}) do
    {:ok, %{body: %{"richMenuId" => id}} } = LineBot.APIClient.post("richmenu", data)

    :timer.sleep(2000)
    link_menu_image(name, id)
    :timer.sleep(2000)
    Repo.create(id, name)
  end

  def link_menu_image(name, remote_id) do
    cmd_path = @bin_path <> "/create_lich_menu_image"
    image_path = File.cwd! <> "/" <> @image_path <> "/#{name}.jpg"
    cmd = [cmd_path, remote_id, @token, image_path]

    [cmd_name | opt] = cmd
    System.cmd(cmd_name, opt)
  end

  def tap(enumerable, fun) do
    enumerable
    |> Enum.each(fun)
    enumerable
  end

  def set_default_menu(%{name: name}) do
    menu_id = Repo.find_by_name(name).remote_id
    LineBot.APIClient.post("/user/all/richmenu/#{menu_id}", %{})
  end

  def targets() do
    [TopMenu]
    |> Enum.map(&concat/1)
  end

  defp concat(mod), do: Module.concat(NarouUpdateNotifyBot.RichMenu, mod)
end
