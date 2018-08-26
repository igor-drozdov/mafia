defmodule Playground.Factory do
  use ExMachina.Ecto, repo: Playground.Repo

  def game_factory do
    %Playground.Mafia.Game{
      state: 0
    }
  end

  def player_factory do
    %Playground.Mafia.Player{
      name: sequence(:name, & "player-#{&1}")
    }
  end

  def round_factory do
    %Playground.Mafia.Round{
      game: build(:game)
    }
  end
end
