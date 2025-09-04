class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.references :game, null: false, foreign_key: true
      t.string :nickname, null: false
      t.integer :score, default: 0
      t.boolean :ready, default: false
      t.datetime :answered_at
      t.string :current_answer

      t.timestamps
    end
  end
end
