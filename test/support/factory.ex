defmodule Mafia.Factory do
  use ExMachina.Ecto, repo: Mafia.Repo

  def game_factory do
    %Mafia.Games.Game{
      state: 0
    }
  end

  def player_factory do
    %Mafia.Players.Player{
      name: sequence(:name, &"player-#{&1}")
    }
  end

  def round_factory do
    %Mafia.Games.Round{
      game: build(:game)
    }
  end

  def player_round_factory do
    round = build(:round)

    %Mafia.Players.Round{
      round: round,
      player: build(:player, game: round.game)
    }
  end

  def player_status_factory do
    %Mafia.Players.Status{
      player_round: build(:player_round)
    }
  end
end
