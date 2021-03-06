defmodule Mafia.Players.Chapters.PlayerChoosesTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Players.Chapters.PlayerChooses
  alias Mafia.Repo

  import Mafia.Factory

  setup do
    game = insert(:game)
    player = insert(:player, game: game)

    {:ok, game: game, player: player}
  end

  test "#notify_player", %{game: game, player: player} do
    @endpoint.subscribe("followers:#{game.id}:#{player.id}")

    other_players = insert_list(3, :player, game: game)
    players = [player | other_players]

    PlayerChooses.notify_player(game.id, player, players)

    assert_broadcast("candidates_received", %{players: ^other_players})
  end

  test "#notify_player_chosen", %{game: game, player: player} do
    @endpoint.subscribe("followers:#{game.id}:#{player.id}")

    PlayerChooses.notify_player_chosen(game.id, player.id)

    assert_broadcast("player_chosen", %{})
  end

  test "#nominate_player", %{game: game, player: player} do
    nominated_by = insert(:player, game: game)
    round = insert(:round)
    player_round = insert(:player_round, round: round, player: player)

    PlayerChooses.nominate_player(round.id, player.id, nominated_by.id)

    player_status =
      Ecto.assoc(player_round, :player_statuses) |> Repo.one() |> Repo.preload(created_by: :game)

    assert player_status.type == :nominated
    assert player_status.created_by == nominated_by
  end
end
