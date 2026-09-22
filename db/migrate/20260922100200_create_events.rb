# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.references :team, null: false, foreign_key: true
      t.string :title, null: false, comment: 'イベント名（練習・試合など）'
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.string :location
      t.integer :participation_fee, comment: '参加費（円）。nilの場合は費用なし'
      t.text :note

      t.timestamps
    end
  end
end
