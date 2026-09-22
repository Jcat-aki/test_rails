# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TeamMembers', type: :request do
  let(:owner) { User.create!(user_name: '幹事太郎', email: 'owner@example.com', password: 'password') }
  let(:other_user) { User.create!(user_name: '別の幹事', email: 'other@example.com', password: 'password') }
  let!(:team) { Team.create!(owner:, name: 'フットサルクラブ') }
  let!(:member) { team.team_members.create!(name: '田中') }

  def login_as(user)
    post login_path, params: { session: { email: user.email, password: 'password' } }
  end

  describe 'POST /teams/:team_id/team_members' do
    it 'ownerはメンバーを登録できる' do
      login_as(owner)
      expect do
        post team_team_members_path(team), params: { team_member: { name: '佐藤' } }
      end.to change(team.team_members, :count).by(1)
    end

    it '他人のTeamにはメンバーを登録できない' do
      login_as(other_user)
      post team_team_members_path(team), params: { team_member: { name: '佐藤' } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /teams/:team_id/team_members/:id/deactivate' do
    it 'ownerはメンバーを無効化できる' do
      login_as(owner)
      patch deactivate_team_team_member_path(team, member)
      expect(member.reload).to be_inactive
    end

    it '他人はメンバーを無効化できない' do
      login_as(other_user)
      patch deactivate_team_team_member_path(team, member)
      expect(response).to have_http_status(:not_found)
    end
  end
end
