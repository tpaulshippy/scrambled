class CountdownJob < ApplicationJob
  def perform(game_id)
    game = Game.find(game_id)
    return unless game.waiting?

    game.start_countdown!
    
    3.times do |i|
      sleep(1)
      Turbo::StreamsChannel.broadcast_replace_to(
        "game_#{game.id}",
        target: "countdown",
        html: "<div id='countdown' class='text-6xl font-bold text-center text-red-500'>#{3 - i}</div>"
      )
    end
    
    sleep(1)
    game.start_playing!
  end
end
