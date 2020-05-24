defmodule NarouUpdateNotifyBot.RichMenu.TopMenu do
  use NarouUpdateNotifyBot.RichMenu

  def data() do
    %{
      size: %{
        width: 2500,
        height: 1686
      },
      selected: false,
      name: "top_menu",
      chatBarText: "トップメニュー",
      areas: [
        areas(x: 0,    y: 0,   w: 833, h: 843, action: %Action.Postback{data: H.postback_data(%{action: "novel/list", type: "read_later"})}),
        areas(x: 833,  y: 0,   w: 833, h: 843, action: %Action.Postback{data: H.postback_data(%{action: "novel/list", type: "update_notify"})}),
        areas(x: 1666, y: 0,   w: 833, h: 843, action: %Action.Postback{data: H.postback_data(%{action: "writer/list"})}),
        areas(x: 0,    y: 843, w: 833, h: 843, action: %Action.Postback{data: H.postback_data(%{action: "user/show_registration_info"})}),
        areas(x: 833,  y: 843, w: 833, h: 843, action: %Action.URI{uri: Application.get_env(:narou_update_notify_bot, :inquery_form_url)}),
        areas(x: 1666, y: 843, w: 833, h: 843, action: %Action.Postback{data: H.postback_data(%{action: "utility/help"})})
      ]
    }
  end
end
