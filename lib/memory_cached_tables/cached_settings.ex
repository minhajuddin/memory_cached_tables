defmodule MCT.CachedSettings do
  use GenServer

  alias MCT.Repo
  alias MCT.Setting
  import Ecto.Query, only: [from: 2]
  require Logger

  defmodule SettingsTable do
    defstruct content_hash: nil, settings_map: %{}
  end

  ## public api

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def all() do
    GenServer.call(__MODULE__, :all)
  end

  ## genserver api
  @polling_interval 1000

  @doc false
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %SettingsTable{}, name: __MODULE__)
  end

  @impl true
  def init(settings_table) do
    schedule_poll()
    {:ok, settings_table, {:continue, :init}}
  end

  @impl true
  def handle_continue(
        {:fetch_data, content_hash},
        settings_table = %SettingsTable{content_hash: content_hash}
      ) do
    Logger.debug(message: "SKIP_FETCH_DATA", content_hash: content_hash)
    {:noreply, settings_table}
  end

  def handle_continue({:fetch_data, content_hash}, settings_table) do
    Logger.debug(message: "FETCHING_NEW_DATA",
      new_content_hash: content_hash,
      old_content_hash: settings_table.content_hash
    )

    settings_table = %SettingsTable{
      content_hash: content_hash,
      settings_map:
        Setting
        |> Repo.all()
        |> Enum.map(fn x -> {x.key, x} end)
        |> Enum.into(%{})
    }

    {:noreply, settings_table}
  end

  def handle_continue(:init, settings_table) do
    {:noreply, settings_table, {:continue, {:fetch_data, get_content_hash(Setting)}}}
  end

  @impl true
  def handle_info(:poll_db, settings_table) do
    schedule_poll()
    {:noreply, settings_table, {:continue, {:fetch_data, get_content_hash(Setting)}}}
  end

  @impl true
  def handle_call(:all, _from, settings_table) do
    {:reply, Map.values(settings_table.settings_map), settings_table}
  end

  def handle_call({:get, key}, _from, settings_table) do
    {:reply, settings_table.settings_map[key], settings_table}
  end

  defp schedule_poll() do
    Process.send_after(self(), :poll_db, @polling_interval)
  end

  defp get_content_hash(model) do
    # in SQL below we sort by the whole row, so that order doesn't change every time we compute the hash
    Repo.one(from s in model, select: fragment("md5(array_agg(? ORDER BY ?)::text)", s, s))
  end
end
