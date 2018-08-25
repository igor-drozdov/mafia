defmodule Playground.Mafia.Narrator do
  use DynamicSupervisor

  alias Playground.Mafia.Chapters

  def start_link(game_uuid) do
    DynamicSupervisor.start_link(__MODULE__, game_uuid, name: via(game_uuid))
  end

  def start_child(game_uuid, spec) do
    DynamicSupervisor.start_child(via(game_uuid), spec)
  end

  def run(game_uuid) do
    Chapters.RoundBegins.run(game_uuid)
  end

  def via(game_uuid) do
    {:via, Registry, { Playground.Mafia.Registry, { __MODULE__, game_uuid}}}
  end

  @impl true
  def init(game_uuid) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
