defmodule Mafia.Chapters.VotingBeginsTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Chapters.{VotingBegins, RoundBegins}
  alias Mafia.Players.Round

  import Mafia.Factory

  setup do
    game = insert(:game)

    {:ok, game_uuid: game.id}
  end

  describe "#notify_players" do
    test "broadcast candidates received", %{game_uuid: game_uuid} do
      nominated = insert(:player, game_id: game_uuid)
      another_nominated = insert(:player, game_id: game_uuid)
      general = insert(:player, game_id: game_uuid)
      players = [nominated, another_nominated, general]

      sockets =
        Enum.map([nominated, another_nominated, general], fn player ->
          {:ok, _, socket} =
            socket("user_id", %{})
            |> join(
              MafiaWeb.Followers.Channel,
              "followers:#{game_uuid}:#{player.id}"
            )

          socket
        end)

      round = RoundBegins.create_round(game_uuid, players)

      Round.create_status(round.id, nominated.id, :nominated)
      Round.create_status(round.id, another_nominated.id, :nominated)

      VotingBegins.notify_players(game_uuid, round.id, players)

      [
        {nominated, [another_nominated]},
        {another_nominated, [nominated]},
        {general, [nominated, another_nominated]}
      ]
      |> Enum.each(fn {player, players} ->
        uuids = "#{game_uuid}:#{player.id}"
        payload = %{players: players}

        assert_receive %Phoenix.Socket.Message{
          event: "candidates_received",
          join_ref: nil,
          payload: ^payload,
          ref: nil,
          topic: "followers:" <> ^uuids
        }
      end)

      assert VotingBegins.all_players_voted?(players, 2)

      Enum.each(sockets, &leave(&1))
    end
  end

  describe "#notify_player_chosen" do
    test "broadcasts player chosen", %{game_uuid: game_uuid} do
      player = insert(:player, game_id: game_uuid)
      @endpoint.subscribe("followers:#{game_uuid}:#{player.id}")

      VotingBegins.notify_player_chosen(game_uuid, player.id)

      assert_broadcast("player_chosen", %{})
    end
  end
end
