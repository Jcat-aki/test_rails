# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :event, null: false, foreign_key: true
      t.references :team_member, null: false, foreign_key: true
      t.integer :amount, null: false, comment: '参加費（円）'
      t.integer :status, null: false, default: 0, comment: '0: unpaid, 1: paid'
      t.datetime :paid_at

      t.timestamps

      t.index %i[event_id team_member_id], unique: true
    end
  end
end
