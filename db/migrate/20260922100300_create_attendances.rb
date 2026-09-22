# frozen_string_literal: true

class CreateAttendances < ActiveRecord::Migration[7.1]
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :attendances do |t|
      t.references :event, null: false, foreign_key: true
      t.references :team_member, null: false, foreign_key: true
      t.integer :status, null: false, default: 0, comment: '0: unanswered, 1: attending, 2: absent, 3: undecided'
      t.string :public_token, null: false, comment: 'ログイン不要の回答用URLに使う推測困難なトークン'
      t.text :comment
      t.datetime :responded_at

      t.timestamps

      t.index %i[event_id team_member_id], unique: true
      t.index :public_token, unique: true
    end
  end
  # rubocop:enable Metrics/MethodLength
end
