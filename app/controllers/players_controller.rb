class PlayersController < ApplicationController
  before_action :set_player
  before_action :set_game

  def create
    @player = @game.players.build(player_params)

    if @player.save
      session[:player_id] = @player.id
      redirect_to @game, notice: "Welcome to the game, #{@player.nickname}!"
    else
      render json: { errors: @player.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @player.update(player_params)
      redirect_to @game, notice: "Profile updated!"
    else
      render json: { errors: @player.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def ready
    unless @player
      render json: { error: "Player not found" }, status: :unprocessable_entity
      return
    end

    if @player.mark_ready!
      head :ok
    else
      render json: { errors: @player.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def submit_answer
    unless @player
      render json: { error: "Player not found" }, status: :unprocessable_entity
      return
    end

    answer = params[:answer]

    if answer.present?
      is_correct = @player.submit_answer!(answer)
      render json: {
        correct: is_correct,
        message: is_correct ? "Correct!" : "Try again!"
      }
    else
      render json: { error: "Answer cannot be blank" }, status: :unprocessable_entity
    end
  end

  private

  def set_player
    @player = Player.find_by(id: session[:player_id]) if session[:player_id]
  end

  def set_game
    @game = @player&.game || Game.find(params[:game_id])
  end

  def player_params
    params.require(:player).permit(:nickname)
  end
end
