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

  def player_round_factory do
    round = build(:round)
    %Playground.Mafia.PlayerRound{
      round: round,
      player: build(:player, game: round.game)
    }
  end

  def player_status_factory do
    %Playground.Mafia.PlayerStatus{
      player_round: build(:player_round)
    }
  end
end
