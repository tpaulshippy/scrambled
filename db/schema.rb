# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_04_044735) do
  create_table "games", force: :cascade do |t|
    t.string "code", limit: 4, null: false
    t.string "state", default: "waiting", null: false
    t.string "current_word"
    t.string "scrambled_word"
    t.integer "round_number", default: 1
    t.integer "max_score", default: 5
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_games_on_code", unique: true
  end

  create_table "players", force: :cascade do |t|
    t.integer "game_id", null: false
    t.string "nickname", null: false
    t.integer "score", default: 0
    t.boolean "ready", default: false
    t.datetime "answered_at"
    t.string "current_answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_players_on_game_id"
  end

  add_foreign_key "players", "games"
end
