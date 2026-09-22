# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id                               :bigint           not null, primary key
#  name(チーム名)                   :string(255)      not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  owner_id(チーム作成者(users.id)) :bigint           not null
#
# Indexes
#
#  index_teams_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
require 'rails_helper'

RSpec.describe Team, type: :model do
  let(:owner) { User.create!(user_name: '幹事太郎', email: 'kanji@example.com', password: 'password') }

  describe 'validation' do
    it 'name が無いと invalid' do
      team = described_class.new(owner:, name: '')
      expect(team).to be_invalid
    end

    it 'owner が無いと invalid' do
      team = described_class.new(name: 'フットサルクラブ')
      expect(team).to be_invalid
    end

    it '正しい属性なら valid' do
      team = described_class.new(owner:, name: 'フットサルクラブ')
      expect(team).to be_valid
    end
  end

  describe '#team_members' do
    it 'Teamを削除するとTeamMemberも削除される' do
      team = described_class.create!(owner:, name: 'フットサルクラブ')
      team.team_members.create!(name: '田中')

      expect { team.destroy! }.to change(TeamMember, :count).by(-1)
    end
  end
end
