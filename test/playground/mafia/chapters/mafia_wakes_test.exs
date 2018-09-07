defmodule Playground.Mafia.Chapters.MafiaWakesTest do
  use PlaygroundWeb.ChannelCase

  alias Playground.Mafia.{Chapters.MafiaWakes, Player}
  alias Playground.Repo

  import Playground.Factory

  describe "#handle_run" do
    test "notity leader and mafia players" do
      game = insert(:game)
      mafia = insert(:player, game_id: game.id, role: :mafia)
      innocent = insert(:player, game_id: game.id, role: :innocent)
      game_uuid = game.id

      {:ok, _, socket} =
        socket("user_id", %{some: :assign})
        |> join(
          PlaygroundWeb.Followers.CurrentChannel,
          "followers:current:#{game_uuid}:#{mafia.id}"
        )

      {:ok, _, leader_socket} =
        socket("user_id", %{some: :assign})
        |> join(
          PlaygroundWeb.Leader.CurrentChannel,
          "leader:current:#{game_uuid}"
        )

      MafiaWakes.handle_run(%{game_uuid: game_uuid, players: [mafia, innocent]})

      assert_receive %Phoenix.Socket.Message{
        event: "play_audio",
        join_ref: nil,
        payload: %{audio: "mafia_wakes"},
        ref: nil,
        topic: "leader:current:" <> game_uuid
      }

      uuids = "#{game_uuid}:#{mafia.id}"
      payload = %{players: [%{id: innocent.id, name: innocent.name}]}

      assert_receive %Phoenix.Socket.Message{
        event: "candidates_received",
        join_ref: nil,
        payload: ^payload,
        ref: nil,
        topic: "followers:current:" <> ^uuids
      }

      leave(socket)
      leave(leader_socket)
    end
  end

  describe "#ostracize_player" do
    test "creates ostracized status for a player" do
      player_round = insert(:player_round)
      game_uuid = player_round.round.game_id
      incity = insert(:player, game_id: game_uuid, role: :innocent)

      MafiaWakes.ostracize_player(player_round.round_id, player_round.player_id)

      assert Repo.all(Player.incity(game_uuid)) == [incity]
    end
  end
end
