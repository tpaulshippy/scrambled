class CountdownJob < ApplicationJob
  def perform(game_id, countdown_step = 3)
    game = Game.find(game_id)
    return unless game.countdown?

    if countdown_step > 0
      # Broadcast current countdown number
      Turbo::StreamsChannel.broadcast_replace_to(
        "game_#{game.id}",
        target: "countdown",
        html: "<div id='countdown' class='text-6xl font-bold text-center text-red-500'>#{countdown_step}</div>"
      )

      # Schedule next countdown step
      CountdownJob.set(wait: 1.second).perform_later(game_id, countdown_step - 1)
    else
      # Countdown finished, start the game
      game.start_playing!
    end
  end
end
