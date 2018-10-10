defmodule Playground.Mafia.Chapters.HandoutRolesTest do
  use PlaygroundWeb.ChannelCase

  alias Playground.Mafia.{Chapters.HandoutRoles, Player}
  alias Playground.Repo
  alias PlaygroundWeb.Followers.InitChannel

  import Playground.Factory

  def run(game_uuid) do
    HandoutRoles.handout_roles(game_uuid)

    Enum.split_with(Repo.all(Player), &(&1.role == :mafia))
  end

  setup do
    game = insert(:game)
    players = insert_list(7, :player, game_id: game.id)

    {:ok, game_uuid: game.id, players: players}
  end

  describe "#handout_roles" do
    test "update roles of players", %{game_uuid: game_uuid} do
      {mafias, innocents} = run(game_uuid)

      assert length(mafias) == 2
      assert length(innocents) == 5
    end

    test "broadcast roles to players", %{game_uuid: game_uuid, players: players} do
      sockets =
        Enum.map(players, fn player ->
          {:ok, _, socket} =
            socket("user_id", %{some: :assign})
            |> join(InitChannel, "followers:init:#{game_uuid}:#{player.id}")

          socket
        end)

      {mafias, innocents} = run(game_uuid)

      Enum.each(Enum.zip(mafias, Enum.reverse(mafias)), fn {player, other_player} ->
        uuids = "#{game_uuid}:#{player.id}"
        other_player = %{ other_player | role: nil }

        assert_receive %Phoenix.Socket.Message{
          event: "role_received",
          payload: %{role: :mafia, players: [^other_player]},
          topic: "followers:init:" <> ^uuids
        }
      end)

      Enum.each(innocents, fn player ->
        uuids = "#{game_uuid}:#{player.id}"

        assert_receive %Phoenix.Socket.Message{
          event: "role_received",
          payload: %{role: :innocent, players: []},
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
