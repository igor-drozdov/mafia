defmodule Playground.PlayerTest do
  use Playground.DataCase

  alias Playground.Repo
  alias Mafia.Players.{Player, Round}
  alias Playground.Mafia.Chapters.RoundBegins

  import Playground.Factory

  setup do
    game = insert(:game)

    ostricized_player = insert(:player, game: game)
    nominated_player = insert(:player, game: game)
    previously_nominated_player = insert(:player, game: game)
    previously_ostricized_player = insert(:player, game: game)
    deprecated_player = insert(:player, game: game)
    deprecated_and_ostricized_player = insert(:player, game: game)

    previous_round = RoundBegins.create_round(game.id, Repo.preload(game, :players).players)

    PlayerRound.create_status(previous_round.id, previously_nominated_player.id, :nominated)
    PlayerRound.create_status(previous_round.id, previously_ostricized_player.id, :ostracized)

    round = RoundBegins.create_round(game.id, Repo.preload(game, :players).players)

    PlayerRound.create_status(round.id, ostricized_player.id, :ostracized)
    PlayerRound.create_status(round.id, nominated_player.id, :nominated)
    PlayerRound.create_status(round.id, nominated_player.id, :nominated)
    PlayerRound.create_status(round.id, deprecated_player.id, :nominated)
    PlayerRound.create_status(round.id, deprecated_player.id, :deprecated)
    PlayerRound.create_status(round.id, deprecated_and_ostricized_player.id, :deprecated)
    PlayerRound.create_status(round.id, deprecated_and_ostricized_player.id, :ostracized)

    {:ok,
     game: game,
     round: round,
     nominated_player: nominated_player,
     previously_nominated_player: previously_nominated_player,
     deprecated_player: deprecated_player,
     ostricized_player: ostricized_player,
     deprecated_and_ostricized_player: deprecated_and_ostricized_player}
  end

  describe "#incity" do
    test "returns only incity players", %{
      game: game,
      nominated_player: nominated_player,
      previously_nominated_player: previously_nominated_player,
      deprecated_player: deprecated_player
    } do
      incity_players = Player.incity(game.id) |> Repo.all() |> Repo.preload(:game)

      assert incity_players == [deprecated_player, previously_nominated_player, nominated_player]
    end
  end

  describe "#by_status" do
    def get_players(round, state) do
      Player.by_status(round.id, state)
      |> order_by([p], asc: p.inserted_at)
      |> Repo.all()
      |> Repo.preload(:game)
    end

    test "returns only nominated players", %{
      round: round,
      nominated_player: nominated_player,
      deprecated_player: deprecated_player
    } do
      nominated_players = get_players(round, :nominated)

      assert nominated_players == [nominated_player, deprecated_player]
    end

    test "returns only deprecated players", %{
      round: round,
      deprecated_player: deprecated_player,
      deprecated_and_ostricized_player: deprecated_and_ostricized_player
    } do
      deprecated_players = get_players(round, :deprecated)

      assert deprecated_players == [deprecated_player, deprecated_and_ostricized_player]
    end

    test "returns only ostracized players", %{
      round: round,
      deprecated_and_ostricized_player: deprecated_and_ostricized_player,
      ostricized_player: ostricized_player
    } do
      ostricized_players = get_players(round, :ostracized)

      assert ostricized_players == [ostricized_player, deprecated_and_ostricized_player]
    end
  end
end
