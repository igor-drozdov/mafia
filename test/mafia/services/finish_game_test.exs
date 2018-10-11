defmodule Mafia.Services.FinishGameTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Services.FinishGame
  alias Mafia.{Repo, Games}

  import Playground.Factory

  setup do
    game = insert(:game)
    {:ok, game: game}
  end

  describe "state of the game and winner" do
    test "updates the game to finished state and creates a winner", %{game: game} do
      FinishGame.run(game.id, winner: :mafia)

      game = Games.get_game(game.id) |> Repo.preload(:winner)

      assert game.state == :finished
      assert game.winner.state == :mafia
    end
  end

  describe "#notify_leader" do
    test "broadcast game finished", %{game: game} do
      game_uuid = game.id

      @endpoint.subscribe("leader:current:#{game_uuid}")
      FinishGame.notify_leader(game_uuid)

      assert_broadcast("finish_game", %{game_id: ^game_uuid, state: :finished})
    end
  end
end
