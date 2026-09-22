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

ActiveRecord::Schema[7.1].define(version: 2026_09_22_100100) do
  create_table "tasks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", null: false, comment: "タスクのタイトル"
    t.date "limit_date", comment: "終了期日"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "finished_at", comment: "終了日時を格納する"
    t.bigint "team_id"
    t.index ["team_id"], name: "index_tasks_on_team_id"
  end

  create_table "team_members", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "user_id", comment: "アプリのログインユーザーと紐付く場合のみ設定"
    t.string "name", null: false, comment: "メンバー表示名"
    t.string "email", comment: "任意。出欠URL通知等に将来利用"
    t.integer "status", default: 0, null: false, comment: "0: active, 1: inactive"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_members_on_team_id"
    t.index ["user_id"], name: "index_team_members_on_user_id"
  end

  create_table "teams", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false, comment: "チーム名"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "owner_id", null: false, comment: "チーム作成者(users.id)"
    t.index ["owner_id"], name: "index_teams_on_owner_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_name", null: false, comment: "ユーザ名"
    t.string "email", null: false, comment: "メールアドレス"
    t.string "password_digest", null: false, comment: "暗号化されたパスワード"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "tasks", "teams"
  add_foreign_key "team_members", "teams"
  add_foreign_key "team_members", "users"
  add_foreign_key "teams", "users", column: "owner_id"
end
