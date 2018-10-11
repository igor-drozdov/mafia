defmodule Mafia.GamesSupervisor do
  use DynamicSupervisor

  alias Mafia.Narrator

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(game_uuid) do
    DynamicSupervisor.start_child(__MODULE__, {Narrator, game_uuid})
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
