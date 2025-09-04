class Game < ApplicationRecord
  has_many :players, dependent: :destroy

  validates :code, presence: true, uniqueness: true, length: { is: 4 }
  validates :state, presence: true, inclusion: { in: %w[waiting countdown playing finished] }
  validates :max_score, presence: true, numericality: { greater_than: 0 }

  before_validation :generate_code, on: :create

  scope :active, -> { where.not(state: "finished") }

  def waiting?
    state == "waiting"
  end

  def countdown?
    state == "countdown"
  end

  def playing?
    state == "playing"
  end

  def finished?
    state == "finished"
  end

  def all_players_ready?
    players.count >= 2 && players.all?(&:ready?)
  end

  def winner
    return nil unless finished?
    players.order(score: :desc).first
  end

  def start_countdown!
    update!(state: "countdown")
    broadcast_game_update
  end

  def start_playing!
    new_word = WordService.random_word
    update!(
      state: "playing",
      current_word: new_word,
      scrambled_word: WordService.scramble(new_word),
      started_at: Time.current
    )
    broadcast_game_update
  end

  def next_round!
    current_winner = players.order(score: :desc).first
    if current_winner&.score >= max_score
      finish_game!
    else
      self.round_number += 1
      start_playing!
    end
  end

  def finish_game!
    update!(state: "finished", finished_at: Time.current)
    broadcast_game_update
  end

  def broadcast_game_update
    return if Rails.env.test?

    broadcast_replace_to("game_#{id}", target: "game_status", partial: "games/game_status", locals: { game: self })
    broadcast_replace_to("game_#{id}", target: "players_list", partial: "games/players_list", locals: { game: self })
  end

  private

  def generate_code
    loop do
      self.code = 4.times.map { rand(10) }.join
      break unless Game.exists?(code: code)
    end
  end
end
