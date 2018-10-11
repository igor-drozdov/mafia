defmodule Mafia.Services.FinishGame do
  alias Mafia.{Games.Game, Games, Repo}
  alias MafiaWeb.Endpoint

  import Ecto.Query

  def run(game_uuid, winner: winner_state) do
    update_game(game_uuid)
    create_winner(game_uuid, winner_state)
    notify_leader(game_uuid)
  end

  def update_game(game_uuid) do
    from(Game, where: [id: ^game_uuid])
    |> Repo.update_all(set: [state: :finished])
  end

  def create_winner(game_uuid, winner_state) do
    Games.create_winner(%{state: winner_state, game_id: game_uuid})
  end

  def notify_leader(game_uuid) do
    payload = %{game_id: game_uuid, state: :finished}
    Endpoint.broadcast("leader:current:#{game_uuid}", "finish_game", payload)
  end
end
