require 'rails_helper'

RSpec.describe WordService do
  describe '.random_word' do
    it 'returns a word from the word list' do
      word = WordService.random_word
      expect(WordService::WORDS).to include(word)
    end

    it 'returns different words on multiple calls' do
      words = 10.times.map { WordService.random_word }
      expect(words.uniq.length).to be > 1
    end
  end

  describe '.scramble' do
    it 'returns a scrambled version of the word' do
      original = 'hello'
      scrambled = WordService.scramble(original)
      
      expect(scrambled).not_to eq(original)
      expect(scrambled.chars.sort).to eq(original.chars.sort)
    end

    it 'returns the same word for single character' do
      expect(WordService.scramble('a')).to eq('a')
    end

    it 'returns the same word for empty string' do
      expect(WordService.scramble('')).to eq('')
    end

    it 'ensures scrambled word is different from original for multi-character words' do
      word = 'test'
      different_found = false
      100.times do
        scrambled = WordService.scramble(word)
        if scrambled != word
          expect(scrambled.chars.sort).to eq(word.chars.sort)
          different_found = true
          break
        end
      end
      expect(different_found).to be true
    end
  end

  describe '.validate_word' do
    it 'returns true for valid words' do
      expect(WordService.validate_word('apple')).to be true
      expect(WordService.validate_word('APPLE')).to be true
    end

    it 'returns false for invalid words' do
      expect(WordService.validate_word('invalidword')).to be false
      expect(WordService.validate_word('xyz')).to be false
    end

    it 'returns false for empty string' do
      expect(WordService.validate_word('')).to be false
    end

    it 'returns false for nil' do
      expect(WordService.validate_word(nil)).to be false
    end
  end

  describe 'word list' do
    it 'contains a reasonable number of words' do
      expect(WordService::WORDS.length).to be >= 50
    end

    it 'contains only valid strings' do
      WordService::WORDS.each do |word|
        expect(word).to be_a(String)
        expect(word.length).to be > 0
        expect(word).to match(/\A[a-z]+\z/)
      end
    end

    it 'contains no duplicates' do
      expect(WordService::WORDS.uniq).to eq(WordService::WORDS)
    end
  end
end
