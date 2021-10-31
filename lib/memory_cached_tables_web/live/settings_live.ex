defmodule MCTWeb.SettingsLive do
  use MCTWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    {:ok, assign(socket, settings: MCT.CachedSettings.all())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <table>
      <%= for setting <- @settings do %>
        <tr>
        <th><%= setting.key %></th>
        <td><%= setting.value %></td>
        </tr>
      <% end %>
    </table>
    """
  end
end
