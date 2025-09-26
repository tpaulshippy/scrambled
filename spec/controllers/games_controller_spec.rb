require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns active games' do
      active_game = Game.create!(max_score: 5, state: 'waiting')
      finished_game = Game.create!(max_score: 5, state: 'finished')

      get :index
      expect(assigns(:games)).to include(active_game)
      expect(assigns(:games)).not_to include(finished_game)
    end

    context 'when code parameter is provided' do
      let(:game) { Game.create!(max_score: 5) }

      it 'redirects to join game page for valid code' do
        get :index, params: { code: game.code }
        expect(response).to redirect_to(join_game_path(game))
      end

      it 'shows error for invalid code' do
        get :index, params: { code: '9999' }
        expect(flash[:alert]).to include('Game not found')
      end
    end
  end

  describe 'GET #show' do
    let(:game) { Game.create!(max_score: 5) }

    it 'returns a successful response for valid game' do
      get :show, params: { id: game.id }
      expect(response).to be_successful
    end

    it 'redirects to root for invalid game' do
      get :show, params: { id: 99999 }
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new game' do
      get :new
      expect(assigns(:game)).to be_a_new(Game)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new game' do
        expect {
          post :create, params: { game: { max_score: 5 } }
        }.to change(Game, :count).by(1)
      end

      it 'redirects to the new game' do
        post :create, params: { game: { max_score: 5 } }
        expect(response).to redirect_to(Game.last)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new game' do
        expect {
          post :create, params: { game: { max_score: 0 } }
        }.not_to change(Game, :count)
      end

      it 'renders the new template' do
        post :create, params: { game: { max_score: 0 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #join' do
    let(:game) { Game.create!(max_score: 5) }

    it 'returns a successful response' do
      get :join, params: { id: game.id }
      expect(response).to be_successful
    end

    it 'assigns a new player' do
      get :join, params: { id: game.id }
      expect(assigns(:player)).to be_a_new(Player)
    end
  end

  describe 'POST #join' do
    let(:game) { Game.create!(max_score: 5) }

    context 'with valid parameters' do
      it 'creates a new player' do
        expect {
          post :join, params: { id: game.id, player: { nickname: 'TestPlayer' } }
        }.to change(Player, :count).by(1)
      end

      it 'sets the player in session' do
        post :join, params: { id: game.id, player: { nickname: 'TestPlayer' } }
        expect(session[:player_id]).to eq(Player.last.id)
      end

      it 'redirects to the game' do
        post :join, params: { id: game.id, player: { nickname: 'TestPlayer' } }
        expect(response).to redirect_to(game)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new player' do
        expect {
          post :join, params: { id: game.id, player: { nickname: '' } }
        }.not_to change(Player, :count)
      end

      it 'renders the join template' do
        post :join, params: { id: game.id, player: { nickname: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
