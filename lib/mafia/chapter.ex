defmodule Playground.Mafia.Chapter do
  defmacro __using__(_opts) do
    quote location: :keep do
      use GenServer

      def start_link(%{game_uuid: game_uuid} = state) do
        GenServer.start_link(__MODULE__, state, name: via(game_uuid))
      end

      def via(game_uuid) do
        {:via, Registry, {Playground.Mafia.Registry, {__MODULE__, game_uuid}}}
      end

      def init(state) do
        {:ok, state}
      end

      def run(game_uuid, state \\ %{}) do
        initial_state = Map.put(state, :game_uuid, game_uuid)

        spec = %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [initial_state]},
          restart: :transient
        }

        {:ok, pid} = Playground.Mafia.Narrator.start_child(game_uuid, spec)
        GenServer.cast(pid, :run)
      end

      def handle_cast(:run, %{game_uuid: game_uuid} = state) do
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
