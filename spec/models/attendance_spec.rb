# frozen_string_literal: true

# == Schema Information
#
# Table name: attendances
#
#  id                                                            :bigint           not null, primary key
#  comment                                                       :text(65535)
#  public_token(ログイン不要の回答用URLに使う推測困難なトークン) :string(255)      not null
#  responded_at                                                  :datetime
#  status(0: unanswered, 1: attending, 2: absent, 3: undecided)  :integer          default("unanswered"), not null
#  created_at                                                    :datetime         not null
#  updated_at                                                    :datetime         not null
#  event_id                                                      :bigint           not null
#  team_member_id                                                :bigint           not null
#
# Indexes
#
#  index_attendances_on_event_id                     (event_id)
#  index_attendances_on_event_id_and_team_member_id  (event_id,team_member_id) UNIQUE
#  index_attendances_on_public_token                 (public_token) UNIQUE
#  index_attendances_on_team_member_id               (team_member_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (team_member_id => team_members.id)
#
require 'rails_helper'

RSpec.describe Attendance, type: :model do
  let(:owner) { User.create!(user_name: '幹事太郎', email: 'kanji@example.com', password: 'password') }
  let(:team) { Team.create!(owner:, name: 'フットサルクラブ') }
  # Event#after_create が「作成時点でactiveなTeamMember」を対象にAttendanceを作るため、
  # member は event より先に実体化させておく必要がある
  let!(:member) { team.team_members.create!(name: '田中') }
  let(:event) { team.events.create!(title: '練習試合', starts_at: Time.zone.now) }

  describe 'public_token' do
    it '自動採番される' do
      attendance = event.attendances.find_by(team_member: member)
      expect(attendance.public_token).to be_present
    end

    it '一意である' do
      team.team_members.create!(name: '佐藤')
      other_event = team.events.create!(title: '試合2', starts_at: Time.zone.now)

      tokens = event.attendances.map(&:public_token) + other_event.attendances.map(&:public_token)

      expect(tokens.uniq.size).to eq(tokens.size)
    end
  end

  describe 'uniqueness' do
    it '同じevent×team_memberの組は重複できない' do
      duplicate = event.attendances.new(team_member: member)
      expect(duplicate).to be_invalid
    end
  end

  describe '#respond!' do
    let(:attendance) { event.attendances.find_by(team_member: member) }

    before { attendance.respond!(status: :attending, comment: 'よろしくお願いします') }

    it 'status/comment が更新される' do
      expect(attendance.reload).to have_attributes(status: 'attending', comment: 'よろしくお願いします')
    end

    it 'responded_at が設定される' do
      expect(attendance.responded_at).to be_present
    end
  end
end
