defmodule Mafia.Chapters.AnnouncementTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Chapters.Announcement
  alias Mafia.Chapters.RoundBegins
  alias Mafia.Players.{Round, Player}
  alias Playground.Repo

  import Playground.Factory

  setup do
    game = insert(:game)

    {:ok, game: game}
  end

  describe "#notify_leader" do
    test "broadcast city wakes", %{game: game} do
      @endpoint.subscribe("leader:current:#{game.id}")
      player = insert(:player, game: game)

      Announcement.notify_leader(game.id, player)

      assert_broadcast("city_wakes", %{players: [^player]})
    end
  end

  describe "#ostracize_deprecated_player" do
    test "broadcast city wakes", %{game: game} do
      player = insert(:player, game: game)
      another_player = insert(:player, game: game)

      round = RoundBegins.create_round(game.id, Repo.preload(game, :players).players)

      PlayerRound.create_status(round.id, player.id, :deprecated)
      PlayerRound.create_status(round.id, player.id, :deprecated)
      PlayerRound.create_status(round.id, another_player.id, :deprecated)

      Announcement.ostracize_deprecated_player(round.id)

      ostracized_players =
        Player.by_status(round.id, :ostracized) |> Repo.all() |> Repo.preload(:game)

      assert ostracized_players == [player]
    end
  end
end
