require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      game = Game.new(max_score: 5)
      expect(game).to be_valid
    end

    it 'auto-generates a code when not provided' do
      game = Game.new(max_score: 5)
      expect(game).to be_valid
      expect(game.code).to match(/\A\d{4}\z/)
    end

    it 'requires a valid state' do
      game = Game.new(max_score: 5, state: 'invalid')
      expect(game).not_to be_valid
    end

    it 'requires max_score to be positive' do
      game = Game.new(max_score: 0)
      expect(game).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'generates a unique 4-digit code on creation' do
      game = Game.create!(max_score: 5)
      expect(game.code).to match(/\A\d{4}\z/)
    end

    it 'generates unique codes for multiple games' do
      game1 = Game.create!(max_score: 5)
      game2 = Game.create!(max_score: 5)
      expect(game1.code).not_to eq(game2.code)
    end
  end

  describe 'associations' do
    it 'has many players' do
      game = Game.create!(max_score: 5)
      player1 = game.players.create!(nickname: 'Player1')
      player2 = game.players.create!(nickname: 'Player2')
      
      expect(game.players).to include(player1, player2)
    end

    it 'destroys players when game is destroyed' do
      game = Game.create!(max_score: 5)
      player = game.players.create!(nickname: 'Player1')
      
      expect { game.destroy }.to change { Player.count }.by(-1)
    end
  end

  describe 'state methods' do
    let(:game) { Game.create!(max_score: 5) }

    it 'defaults to waiting state' do
      expect(game.waiting?).to be true
    end

    it 'can transition to countdown state' do
      game.update!(state: 'countdown')
      expect(game.countdown?).to be true
    end

    it 'can transition to playing state' do
      game.update!(state: 'playing')
      expect(game.playing?).to be true
    end

    it 'can transition to finished state' do
      game.update!(state: 'finished')
      expect(game.finished?).to be true
    end
  end

  describe '#all_players_ready?' do
    let(:game) { Game.create!(max_score: 5) }

    it 'returns false with no players' do
      expect(game.all_players_ready?).to be false
    end

    it 'returns true with one ready player' do
      game.players.create!(nickname: 'Player1', ready: true)
      expect(game.all_players_ready?).to be true
    end

    it 'returns false with one unready player' do
      game.players.create!(nickname: 'Player1', ready: false)
      expect(game.all_players_ready?).to be false
    end

    it 'returns false when not all players are ready' do
      game.players.create!(nickname: 'Player1', ready: true)
      game.players.create!(nickname: 'Player2', ready: false)
      expect(game.all_players_ready?).to be false
    end

    it 'returns true when all players (2+) are ready' do
      game.players.create!(nickname: 'Player1', ready: true)
      game.players.create!(nickname: 'Player2', ready: true)
      expect(game.all_players_ready?).to be true
    end
  end

  describe '#winner' do
    let(:game) { Game.create!(max_score: 5, state: 'finished') }

    it 'returns nil for unfinished games' do
      game.update!(state: 'playing')
      expect(game.winner).to be_nil
    end

    it 'returns the player with highest score' do
      player1 = game.players.create!(nickname: 'Player1', score: 3)
      player2 = game.players.create!(nickname: 'Player2', score: 5)
      
      expect(game.winner).to eq(player2)
    end
  end
end
