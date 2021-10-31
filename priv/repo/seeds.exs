# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MCT.Repo.insert!(%MCT.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

settings =
  """
  app: MCT
  db: postgres
  browser: firefox
  host: fly.io
  programming_language: elixir
  framework: phoenix
  """
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(fn line ->
    [key, value] = String.split(line, ":") |> Enum.map(&String.trim/1)
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    %{
      key: key,
      value: value,
      inserted_at: now,
      updated_at: now
    }
  end)

MCT.Repo.insert_all(MCT.Setting, settings)
