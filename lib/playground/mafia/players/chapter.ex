defmodule Playground.Mafia.Players.Chapter do
  defmacro __using__(_opts) do
    quote location: :keep do
      use GenServer

      def start_link(%{game_uuid: game_uuid, player: player} = state) do
        GenServer.start_link(__MODULE__, state, name: via(game_uuid, player.id))
      end

      def start(game_uuid, player, state) do
        initial_state = Map.merge(state, %{game_uuid: game_uuid, player: player})

        spec = %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [initial_state]},
          restart: :transient
        }

        {:ok, pid} = Playground.Mafia.Narrator.start_child(game_uuid, spec)

        pid
      end

      def via(game_uuid, player_uuid) do
        {:via, Registry, { Playground.Mafia.Registry, { __MODULE__, game_uuid, player_uuid }}}
      end

      def init(state) do
        {:ok, state}
      end

      def handle_cast({:run, other_players}, %{game_uuid: game_uuid, player: player} = state) do
        Registry.register(Playground.Mafia.Registry, {:current, game_uuid}, via(game_uuid, player.id))

        require Logger
        Logger.info __MODULE__

        case handle_run(other_players, state) do
          {:noreply, new_state} ->
            {:noreply, new_state}
          {:stop, :shutdown, new_state} ->
            {:stop, :shutdown, new_state}
          _ ->
            {:noreply, state}
        end
      end
    end
  end
end
