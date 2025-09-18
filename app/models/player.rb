class Player < ApplicationRecord
  belongs_to :game

  validates :nickname, presence: true, length: { minimum: 1, maximum: 20 }
  validates :nickname, uniqueness: { scope: :game_id }
  validates :score, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :ready, -> { where(ready: true) }
  scope :by_score, -> { order(score: :desc) }

  def mark_ready!
    if update(ready: true)
      check_all_ready
      true
    else
      false
    end
  end

  def submit_answer!(answer)
    self.current_answer = answer.strip.downcase
    self.answered_at = Time.current

    if correct_answer?
      increment_score!
      game.next_round!
    end

    save!
    game.broadcast_game_update
  end

  def correct_answer?
    return false unless game.current_word && current_answer
    current_answer.downcase == game.current_word.downcase
  end

  def increment_score!
    self.score += 1
  end

  def reset_for_new_round!
    update!(current_answer: nil, answered_at: nil)
  end

  private

  def check_all_ready
    return unless game.all_players_ready?

    game.start_countdown!
    CountdownJob.set(wait: 1.second).perform_later(game.id) unless Rails.env.test?
  end
end
