# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams do |t|
      t.string :name, null: false, comment: 'チーム名'
      t.integer :category, null: false, default: 0, comment: '所属チームのカテゴリ'
      t.string :country, null: false, comment: '国名'

      t.timestamps
    end
  end
end
