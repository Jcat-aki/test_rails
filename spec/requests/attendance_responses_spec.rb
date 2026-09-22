# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AttendanceResponses', type: :request do
  let(:owner) { User.create!(user_name: '幹事太郎', email: 'owner@example.com', password: 'password') }
  let(:team) { Team.create!(owner:, name: 'フットサルクラブ') }
  # Event#after_create が作成時点でactiveなTeamMemberを対象にAttendanceを作るため先に作る
  let!(:member) { team.team_members.create!(name: '田中') }
  let(:event) { team.events.create!(title: '練習試合', starts_at: Time.zone.now) }
  let(:attendance) { event.attendances.find_by(team_member: member) }

  describe 'GET /attendance_responses/:public_token' do
    it 'ログインなしで自分の回答画面を見られる' do
      get attendance_response_path(attendance.public_token)
      expect(response).to have_http_status(:ok)
    end

    it '存在しないtokenは404になる' do
      get attendance_response_path('invalid-token')
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /attendance_responses/:public_token' do
    before do
      patch attendance_response_path(attendance.public_token),
            params: { attendance: { status: 'attending', comment: 'よろしくお願いします' } }
      attendance.reload
    end

    it 'ログインなしで出欠(status/comment)を更新できる' do
      expect(attendance).to have_attributes(status: 'attending', comment: 'よろしくお願いします')
    end

    it 'responded_at が設定される' do
      expect(attendance.responded_at).to be_present
    end

    it '存在しないtokenは404になる' do
      patch attendance_response_path('invalid-token'), params: { attendance: { status: 'attending' } }
      expect(response).to have_http_status(:not_found)
    end
  end
end
