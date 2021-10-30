defmodule MCT.Repo do
  use Ecto.Repo,
    otp_app: :memory_cached_tables,
    adapter: Ecto.Adapters.Postgres
end
