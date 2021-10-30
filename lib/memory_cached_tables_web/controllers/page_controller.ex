defmodule MCTWeb.PageController do
  use MCTWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
