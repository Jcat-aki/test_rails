# frozen_string_literal: true

# == Schema Information
#
# Table name: team_members
#
#  id                                                    :bigint           not null, primary key
#  email(任意。出欠URL通知等に将来利用)                  :string(255)
#  name(メンバー表示名)                                  :string(255)      not null
#  status(0: active, 1: inactive)                        :integer          default("active"), not null
#  created_at                                            :datetime         not null
#  updated_at                                            :datetime         not null
#  team_id                                               :bigint           not null
#  user_id(アプリのログインユーザーと紐付く場合のみ設定) :bigint
#
# Indexes
#
#  index_team_members_on_team_id  (team_id)
#  index_team_members_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe TeamMember, type: :model do
  let(:owner) { User.create!(user_name: '幹事太郎', email: 'kanji@example.com', password: 'password') }
  let(:team) { Team.create!(owner:, name: 'フットサルクラブ') }

  describe 'validation' do
    it 'name が無いと invalid' do
      member = team.team_members.new(name: '')
      expect(member).to be_invalid
    end

    it 'email が不正な形式だと invalid' do
      member = team.team_members.new(name: '田中', email: 'not-an-email')
      expect(member).to be_invalid
    end

    it 'email が空欄なら valid' do
      member = team.team_members.new(name: '田中', email: '')
      expect(member).to be_valid
    end
  end

  describe 'status' do
    it 'デフォルトは active' do
      member = team.team_members.create!(name: '田中')
      expect(member).to be_active
    end

    it 'inactive! で無効化できる' do
      member = team.team_members.create!(name: '田中')
      member.inactive!
      expect(member.reload).to be_inactive
    end
  end

  describe '#assigned_tasks' do
    it 'メンバーを削除すると担当タスクのassignee_team_member_idはnilになる' do
      member = team.team_members.create!(name: '田中')
      task = Task.create!(title: 'ボール準備', team:, assignee_team_member: member)

      member.destroy!

      expect(task.reload.assignee_team_member_id).to be_nil
    end
  end
end
