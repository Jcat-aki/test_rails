# frozen_string_literal: true

# Team の意味を「Jリーグの実チーム」から「利用者自身が運営するチーム」へ変更する。
# 移行前提として、既存の teams レコード（Jリーグデータ）は事前に削除しておくこと
# （rake create_japan:teams が Team.destroy_all してきたのと同様の運用）。
class RestructureTeamsForOwnership < ActiveRecord::Migration[7.1]
  def change
    change_table :teams, bulk: true do |t|
      t.remove :category, type: :integer, null: false, default: 0, comment: '所属チームのカテゴリ'
      t.remove :country, type: :string, null: false, comment: '国名'
      t.references :owner, foreign_key: { to_table: :users }, comment: 'チーム作成者(users.id)'
    end

    change_column_null :teams, :owner_id, false
  end
end
