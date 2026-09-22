# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Teams', type: :request do
  let(:owner) { User.create!(user_name: '幹事太郎', email: 'owner@example.com', password: 'password') }
  let(:other_user) { User.create!(user_name: '別の幹事', email: 'other@example.com', password: 'password') }
  let!(:team) { Team.create!(owner:, name: 'フットサルクラブ') }

  def login_as(user)
    post login_path, params: { session: { email: user.email, password: 'password' } }
  end

  describe 'GET /teams/:id' do
    context '自分がownerのTeamの場合' do
      it '閲覧できる' do
        login_as(owner)
        get team_path(team)
        expect(response).to have_http_status(:ok)
      end
    end

    context '他人がownerのTeamの場合' do
      it 'アクセスできない（見つからない扱いになる）' do
        login_as(other_user)
        get team_path(team)
        expect(response).to have_http_status(:not_found)
      end
    end

    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get team_path(team)
        expect(response).to redirect_to(login_url)
      end
    end
  end

  describe 'GET /teams/:id/edit' do
    it '他人がownerのTeamは編集できない' do
      login_as(other_user)
      get edit_team_path(team)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /teams' do
    it 'ログインユーザーがownerとしてチームを作成できる' do
      login_as(owner)
      expect do
        post teams_path, params: { team: { name: '新しいチーム' } }
      end.to change(owner.teams, :count).by(1)
    end
  end
end
