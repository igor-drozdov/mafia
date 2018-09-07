defmodule Playground.Mafia.Chapters.HandoutRolesTest do
  use PlaygroundWeb.ChannelCase

  alias Playground.Mafia.{Chapters.HandoutRoles, Player}
  alias Playground.Repo
  alias PlaygroundWeb.Followers.InitChannel

  import Playground.Factory

  def run(game_uuid, player_uuids) do
    HandoutRoles.handout_roles(game_uuid, player_uuids)

    Enum.split_with(Repo.all(Player), &(&1.role == :mafia))
  end

  setup do
    game = insert(:game)
    player_uuids = insert_list(7, :player, game_id: game.id) |> Enum.map(& &1.id)

    {:ok, game_uuid: game.id, player_uuids: player_uuids}
  end

  describe "#handout_roles" do
    test "update roles of players", %{game_uuid: game_uuid, player_uuids: player_uuids} do
      {mafias, innocents} = run(game_uuid, player_uuids)

      assert length(mafias) == 2
      assert length(innocents) == 5
    end

    test "broadcast roles to players", %{game_uuid: game_uuid, player_uuids: player_uuids} do
      sockets =
        Enum.map(player_uuids, fn player_uuid ->
          {:ok, _, socket} =
            socket("user_id", %{some: :assign})
            |> join(InitChannel, "followers:init:#{game_uuid}:#{player_uuid}")

          socket
        end)

      {mafias, innocents} = run(game_uuid, player_uuids)

      Enum.each(mafias, fn player ->
        uuids = "#{game_uuid}:#{player.id}"

        assert_receive %Phoenix.Socket.Message{
          event: "role_received",
          join_ref: nil,
          payload: %{role: :mafia},
          ref: nil,
          topic: "followers:init:" <> ^uuids
        }
      end)

      Enum.each(innocents, fn player ->
        uuids = "#{game_uuid}:#{player.id}"

        assert_receive %Phoenix.Socket.Message{
          event: "role_received",
          join_ref: nil,
          payload: %{role: :innocent},
          ref: nil,
          topic: "followers:init:" <> ^uuids
        }
      end)

      Enum.map(sockets, &leave(&1))
    end
  end

  describe "#notify_leader" do
    test "broadcast roles assigned", %{game_uuid: game_uuid} do
      @endpoint.subscribe("leader:init:#{game_uuid}")
      HandoutRoles.notify_leader(game_uuid)
      assert_broadcast("roles_assigned", %{audio: "roles_assigned"})
    end
  end
end
