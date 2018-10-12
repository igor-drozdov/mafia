defmodule Mafia.Players.Chapter do
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

        {:ok, pid} = Mafia.Narrator.start_child(game_uuid, spec)

        pid
      end

      def via(game_uuid, player_uuid) do
        {:via, Registry, {Mafia.Registry, {__MODULE__, game_uuid, player_uuid}}}
      end

      def init(state) do
        {:ok, state}
      end

      def handle_cast(:run, %{game_uuid: game_uuid, player: player} = state) do
        require Logger
        Logger.info(__MODULE__)

        case handle_run(state) do
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
