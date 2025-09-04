class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :code, null: false, limit: 4
      t.string :state, null: false, default: 'waiting'
      t.string :current_word
      t.string :scrambled_word
      t.integer :round_number, default: 1
      t.integer :max_score, default: 5
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
    
    add_index :games, :code, unique: true
  end
end
