defmodule Mafia.Narrator do
  use DynamicSupervisor

  def start_link(game_uuid) do
    DynamicSupervisor.start_link(__MODULE__, [], name: via(game_uuid))
  end

  def start_child(game_uuid, spec) do
    DynamicSupervisor.start_child(via(game_uuid), spec)
  end

  def via(game_uuid) do
    {:via, Registry, {Mafia.Registry, {__MODULE__, game_uuid}}}
  end

  def current(game_uuid) do
    {_, pid, _, _} = DynamicSupervisor.which_children(via(game_uuid)) |> List.last()
    pid
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
