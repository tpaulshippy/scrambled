class GamesController < ApplicationController
  before_action :set_game, only: [ :show, :join ]

  def index
    if params[:code].present?
      game = Game.find_by(code: params[:code])
      if game
        redirect_to join_game_path(game)
      else
        flash[:alert] = "Game not found with code #{params[:code]}"
      end
    end

    @games = Game.active.includes(:players)
  end

  def show
    if session[:player_id]
      @current_player = Player.find_by(id: session[:player_id])
      if @current_player&.game != @game
        session[:player_id] = nil
        @current_player = nil
      end
    end

    redirect_to root_path unless @game
  end

  def create
    @game = Game.new(game_params)

    if @game.save
      redirect_to @game, notice: "Game created! Share the code with your friends."
    else
      flash.now[:alert] = "Unable to create game."
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @game = Game.new
  end

  def join
    if request.post?
      @player = @game.players.build(player_params)

      if @player.save
        session[:player_id] = @player.id
        redirect_to @game, notice: "Welcome to the game, #{@player.nickname}!"
      else
        flash.now[:alert] = @player.errors.full_messages.join(", ")
        render :join, status: :unprocessable_entity
      end
    else
      @player = @game.players.build
    end
  end

  private

  def set_game
    @game = Game.find_by(id: params[:id]) || Game.find_by(code: params[:code])
  end

  def game_params
    params.require(:game).permit(:max_score)
  end

  def player_params
    params.require(:player).permit(:nickname)
  end
end
