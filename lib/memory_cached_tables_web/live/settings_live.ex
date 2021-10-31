defmodule MCTWeb.SettingsLive do
  use MCTWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :refresh, 1000)

    {:ok, assign(socket, settings: MCT.CachedSettings.all())}
  end

  @impl true
  def handle_info(:refresh, socket) do
    Process.send_after(self(), :refresh, 1000)
    {:noreply, assign(socket, settings: MCT.CachedSettings.all())}
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
