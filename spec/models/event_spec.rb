# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                                                   :bigint           not null, primary key
#  ends_at                                              :datetime
#  location                                             :string(255)
#  note                                                 :text(65535)
#  participation_fee(参加費（円）。nilの場合は費用なし) :integer
#  starts_at                                            :datetime         not null
#  title(イベント名（練習・試合など）)                  :string(255)      not null
#  created_at                                           :datetime         not null
#  updated_at                                           :datetime         not null
#  team_id                                              :bigint           not null
#
# Indexes
#
#  index_events_on_team_id  (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#
require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:owner) { User.create!(user_name: '幹事太郎', email: 'kanji@example.com', password: 'password') }
  let(:team) { Team.create!(owner:, name: 'フットサルクラブ') }

  describe 'validation' do
    it 'title が無いと invalid' do
      event = team.events.new(title: '', starts_at: Time.zone.now)
      expect(event).to be_invalid
    end

    it 'starts_at が無いと invalid' do
      event = team.events.new(title: '練習試合', starts_at: nil)
      expect(event).to be_invalid
    end
  end

  describe '#build_attendances_for_active_members' do
    let!(:active_member) { team.team_members.create!(name: '田中', status: :active) }
    let!(:inactive_member) { team.team_members.create!(name: '佐藤', status: :inactive) }
    let(:event) { team.events.create!(title: '練習試合', starts_at: Time.zone.now) }

    it 'activeなTeamMemberの分だけAttendanceが作成される' do
      expect(event.attendances.map(&:team_member)).to contain_exactly(active_member)
    end

    it 'inactiveなTeamMemberは対象にならない' do
      expect(event.attendances.map(&:team_member)).not_to include(inactive_member)
    end
  end

  describe '#attendance_summary' do
    let!(:member1) { team.team_members.create!(name: '田中') }
    let!(:member2) { team.team_members.create!(name: '佐藤') }
    let(:event) { team.events.create!(title: '練習試合', starts_at: Time.zone.now) }

    before do
      event.attendances.find_by(team_member: member1).respond!(status: :attending)
      event.attendances.find_by(team_member: member2).respond!(status: :absent)
    end

    it '各ステータスの人数を返す' do
      expect(event.attendance_summary).to eq(unanswered: 0, attending: 1, absent: 1, undecided: 0)
    end
  end
end
