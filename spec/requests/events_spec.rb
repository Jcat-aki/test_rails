# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Events', type: :request do
  let(:owner) { User.create!(user_name: '幹事太郎', email: 'owner@example.com', password: 'password') }
  let(:other_user) { User.create!(user_name: '別の幹事', email: 'other@example.com', password: 'password') }
  let!(:team) { Team.create!(owner:, name: 'フットサルクラブ') }
  let!(:event) { team.events.create!(title: '練習試合', starts_at: Time.zone.now) }

  def login_as(user)
    post login_path, params: { session: { email: user.email, password: 'password' } }
  end

  describe 'GET /teams/:team_id/events/:id' do
    it 'ownerは閲覧できる' do
      login_as(owner)
      get team_event_path(team, event)
      expect(response).to have_http_status(:ok)
    end

    it '他人は閲覧できない' do
      login_as(other_user)
      get team_event_path(team, event)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /teams/:team_id/events' do
    it 'ownerはイベントを作成できる' do
      login_as(owner)
      expect do
        post team_events_path(team), params: { event: { title: '試合', starts_at: Time.zone.now } }
      end.to change(team.events, :count).by(1)
    end

    it '他人はイベントを作成できない' do
      login_as(other_user)
      expect do
        post team_events_path(team), params: { event: { title: '試合', starts_at: Time.zone.now } }
      end.not_to change(Event, :count)
    end

    it '他人がアクセスすると404になる' do
      login_as(other_user)
      post team_events_path(team), params: { event: { title: '試合', starts_at: Time.zone.now } }
      expect(response).to have_http_status(:not_found)
    end
  end
end
