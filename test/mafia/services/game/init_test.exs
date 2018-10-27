defmodule Mafia.Services.Game.InitTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Services.Game.Init
  alias Mafia.Repo

  import Mafia.Factory

  setup do
    game = insert(:game, total: 3, state: :current)
    players = insert_list(2, :player, game: game)

    {:ok, players: players, game: game}
  end

  describe "#all_players_joined?" do
    test "checks whether total number of players joined", %{game: game} do
      refute Init.all_players_joined?(Repo.preload(game, :players))
      insert(:player, game: game)
      assert Init.all_players_joined?(Repo.preload(game, :players))
    end
  end
end
