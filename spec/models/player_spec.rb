require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:game) { Game.create!(max_score: 5) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      player = game.players.build(nickname: 'TestPlayer')
      expect(player).to be_valid
    end

    it 'requires a nickname' do
      player = game.players.build(nickname: nil)
      expect(player).not_to be_valid
    end

    it 'requires nickname to be within length limits' do
      player = game.players.build(nickname: 'a' * 21)
      expect(player).not_to be_valid
    end

    it 'requires unique nickname within game' do
      game.players.create!(nickname: 'Player1')
      player = game.players.build(nickname: 'Player1')
      expect(player).not_to be_valid
    end

    it 'allows same nickname in different games' do
      other_game = Game.create!(max_score: 5)
      game.players.create!(nickname: 'Player1')
      player = other_game.players.build(nickname: 'Player1')
      expect(player).to be_valid
    end

    it 'requires score to be non-negative' do
      player = game.players.build(nickname: 'Player1', score: -1)
      expect(player).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a game' do
      player = game.players.create!(nickname: 'TestPlayer')
      expect(player.game).to eq(game)
    end
  end

  describe 'defaults' do
    it 'defaults ready to false' do
      player = game.players.create!(nickname: 'TestPlayer')
      expect(player.ready?).to be false
    end

    it 'defaults score to 0' do
      player = game.players.create!(nickname: 'TestPlayer')
      expect(player.score).to eq(0)
    end
  end

  describe '#correct_answer?' do
    let(:player) { game.players.create!(nickname: 'TestPlayer') }

    before do
      game.update!(current_word: 'hello')
    end

    it 'returns true for correct answer' do
      player.current_answer = 'hello'
      expect(player.correct_answer?).to be true
    end

    it 'returns true for correct answer with different case' do
      player.current_answer = 'HELLO'
      expect(player.correct_answer?).to be true
    end

    it 'returns false for incorrect answer' do
      player.current_answer = 'world'
      expect(player.correct_answer?).to be false
    end

    it 'returns false when no current_word is set' do
      game.update!(current_word: nil)
      player.current_answer = 'hello'
      expect(player.correct_answer?).to be false
    end

    it 'returns false when no answer is given' do
      player.current_answer = nil
      expect(player.correct_answer?).to be false
    end
  end

  describe '#increment_score!' do
    let(:player) { game.players.create!(nickname: 'TestPlayer', score: 3) }

    it 'increases score by 1' do
      expect { player.increment_score! }.to change { player.score }.from(3).to(4)
    end
  end

  describe '#reset_for_new_round!' do
    let(:player) { game.players.create!(nickname: 'TestPlayer') }

    before do
      player.update!(current_answer: 'test', answered_at: Time.current)
    end

    it 'clears current_answer and answered_at' do
      player.reset_for_new_round!
      expect(player.current_answer).to be_nil
      expect(player.answered_at).to be_nil
    end
  end

  describe 'scopes' do
    before do
      @ready_player = game.players.create!(nickname: 'Ready', ready: true, score: 5)
      @not_ready_player = game.players.create!(nickname: 'NotReady', ready: false, score: 3)
      @high_score_player = game.players.create!(nickname: 'HighScore', ready: true, score: 10)
    end

    describe '.ready' do
      it 'returns only ready players' do
        expect(Player.ready).to include(@ready_player, @high_score_player)
        expect(Player.ready).not_to include(@not_ready_player)
      end
    end

    describe '.by_score' do
      it 'returns players ordered by score descending' do
        expect(Player.by_score).to eq([@high_score_player, @ready_player, @not_ready_player])
      end
    end
  end

  describe '#submit_answer!' do
    let(:player) { game.players.create!(nickname: 'TestPlayer') }

    before do
      game.update!(state: 'playing', current_word: 'hello')
    end

    context 'with correct answer' do
      it 'returns true' do
        result = player.submit_answer!('hello')
        expect(result).to be true
      end

      it 'stores the answer' do
        player.submit_answer!('hello')
        expect(player.current_answer).to eq('hello')
      end

      it 'records the answered_at timestamp' do
        expect { player.submit_answer!('hello') }.to change { player.answered_at }.from(nil)
      end

      it 'increments the score' do
        expect { player.submit_answer!('hello') }.to change { player.score }.by(1)
      end
    end

    context 'with incorrect answer' do
      it 'returns false' do
        result = player.submit_answer!('wrong')
        expect(result).to be false
      end

      it 'stores the answer' do
        player.submit_answer!('wrong')
        expect(player.current_answer).to eq('wrong')
      end

      it 'records the answered_at timestamp' do
        expect { player.submit_answer!('wrong') }.to change { player.answered_at }.from(nil)
      end

      it 'does not increment the score' do
        expect { player.submit_answer!('wrong') }.not_to change { player.score }
      end
    end

    it 'handles case insensitive answers' do
      result = player.submit_answer!('HELLO')
      expect(result).to be true
      expect(player.current_answer).to eq('hello')
    end

    it 'strips whitespace from answers' do
      result = player.submit_answer!('  hello  ')
      expect(result).to be true
      expect(player.current_answer).to eq('hello')
    end
  end
end
