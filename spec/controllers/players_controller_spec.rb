require 'rails_helper'

RSpec.describe PlayersController, type: :controller do
  let(:game) { Game.create!(max_score: 5) }
  let(:player) { game.players.create!(nickname: 'TestPlayer') }

  before do
    session[:player_id] = player.id
  end

  describe 'PATCH #ready' do
    context 'with valid player' do
      it 'marks player as ready' do
        patch :ready, params: { game_id: game.id, id: player.id }
        expect(player.reload.ready?).to be true
      end

      it 'returns successful response' do
        patch :ready, params: { game_id: game.id, id: player.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'without valid player in session' do
      before { session[:player_id] = nil }

      it 'handles missing player gracefully' do
        patch :ready, params: { game_id: game.id, id: player.id }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST #submit_answer' do
    before do
      game.update!(state: 'playing', current_word: 'hello')
    end

    context 'with valid answer' do
      it 'submits the answer' do
        post :submit_answer, params: { 
          game_id: game.id, 
          id: player.id, 
          answer: 'hello' 
        }
        
        expect(player.reload.current_answer).to eq('hello')
      end

      it 'returns successful response' do
        post :submit_answer, params: { 
          game_id: game.id, 
          id: player.id, 
          answer: 'hello' 
        }
        
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with blank answer' do
      it 'returns error response' do
        post :submit_answer, params: { 
          game_id: game.id, 
          id: player.id, 
          answer: '' 
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without valid player in session' do
      before { session[:player_id] = nil }

      it 'handles missing player gracefully' do
        post :submit_answer, params: { 
          game_id: game.id, 
          id: player.id, 
          answer: 'hello' 
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST #create' do
    before { session[:player_id] = nil }

    context 'with valid parameters' do
      it 'creates a new player' do
        expect {
          post :create, params: { 
            game_id: game.id, 
            player: { nickname: 'NewPlayer' } 
          }
        }.to change(Player, :count).by(1)
      end

      it 'sets the player in session' do
        post :create, params: { 
          game_id: game.id, 
          player: { nickname: 'NewPlayer' } 
        }
        
        expect(session[:player_id]).to eq(Player.last.id)
      end

      it 'redirects to the game' do
        post :create, params: { 
          game_id: game.id, 
          player: { nickname: 'NewPlayer' } 
        }
        
        expect(response).to redirect_to(game)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new player' do
        expect {
          post :create, params: { 
            game_id: game.id, 
            player: { nickname: '' } 
          }
        }.not_to change(Player, :count)
      end

      it 'returns error response' do
        post :create, params: { 
          game_id: game.id, 
          player: { nickname: '' } 
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      it 'updates the player' do
        patch :update, params: { 
          game_id: game.id, 
          id: player.id, 
          player: { nickname: 'UpdatedName' } 
        }
        
        expect(player.reload.nickname).to eq('UpdatedName')
      end

      it 'redirects to the game' do
        patch :update, params: { 
          game_id: game.id, 
          id: player.id, 
          player: { nickname: 'UpdatedName' } 
        }
        
        expect(response).to redirect_to(game)
      end
    end

    context 'with invalid parameters' do
      it 'does not update the player' do
        original_nickname = player.nickname
        patch :update, params: { 
          game_id: game.id, 
          id: player.id, 
          player: { nickname: '' } 
        }
        
        expect(player.reload.nickname).to eq(original_nickname)
      end

      it 'returns error response' do
        patch :update, params: { 
          game_id: game.id, 
          id: player.id, 
          player: { nickname: '' } 
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
