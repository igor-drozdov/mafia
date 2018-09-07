defmodule Playground.Mafia.Players.Chapters.PlayerChoosesTest do
  use PlaygroundWeb.ChannelCase

  alias Playground.Mafia.Players.Chapters.PlayerChooses
  alias Playground.Repo

  import Playground.Factory

  setup do
    game = insert(:game)
    player = insert(:player, game: game)

    {:ok, game: game, player: player}
  end

  test "#notify_player", %{game: game, player: player} do
    @endpoint.subscribe("followers:current:#{game.id}:#{player.id}")

    other_players = insert_list(3, :player, game: game)
    players = [player | other_players]

    PlayerChooses.notify_player(game.id, player, players)

    assert_broadcast("candidates_received", %{players: other_players})
  end

  test "#notify_player_chosen", %{game: game, player: player} do
    @endpoint.subscribe("followers:current:#{game.id}:#{player.id}")

    PlayerChooses.notify_player_chosen(game.id, player.id)

    assert_broadcast("player_chosen", %{})
  end

  test "#nominate_player", %{player: player} do
    round = insert(:round)
    player_round = insert(:player_round, round: round, player: player)

    PlayerChooses.nominate_player(round.id, player.id)

    player_status = Ecto.assoc(player_round, :player_statuses) |> Repo.one()

    assert player_status.type == :nominated
  end
end
