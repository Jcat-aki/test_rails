# frozen_string_literal: true

class CreateTeamMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :team_members do |t|
      t.references :team, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true, comment: 'アプリのログインユーザーと紐付く場合のみ設定'
      t.string :name, null: false, comment: 'メンバー表示名'
      t.string :email, null: true, comment: '任意。出欠URL通知等に将来利用'
      t.integer :status, null: false, default: 0, comment: '0: active, 1: inactive'

      t.timestamps
    end
  end
end
