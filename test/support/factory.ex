defmodule Playground.Factory do
  use ExMachina.Ecto, repo: Playground.Repo

  def game_factory do
    %Playground.Mafia.Game{
      state: 0
    }
  end

  def player_factory do
    %Playground.Mafia.Player{
      state: 0,
      name: sequence(:name, & "player-#{&1}")
    }
  end
end
