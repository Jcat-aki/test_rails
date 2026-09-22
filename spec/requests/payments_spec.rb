# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Payments', type: :request do
  let(:owner) { User.create!(user_name: '幹事太郎', email: 'owner@example.com', password: 'password') }
  let!(:team) { Team.create!(owner:, name: 'フットサルクラブ') }
  let!(:member) { team.team_members.create!(name: '田中') }
  let!(:event) { team.events.create!(title: '練習試合', starts_at: Time.zone.now, participation_fee: 1500) }
  let!(:payment) { event.payments.create!(team_member: member, amount: 1500) }

  def login_as(user)
    post login_path, params: { session: { email: user.email, password: 'password' } }
  end

  def other_user
    User.create!(user_name: '別の幹事', email: 'other@example.com', password: 'password')
  end

  describe 'PATCH /teams/:team_id/events/:event_id/payments/:id' do
    it 'ownerは支払済みにできる' do
      login_as(owner)
      patch team_event_payment_path(team, event, payment), params: { payment: { status: 'paid' } }
      expect(payment.reload).to be_paid
    end

    it 'ownerは未払いに戻せる' do
      payment.mark_as_paid!
      login_as(owner)
      patch team_event_payment_path(team, event, payment), params: { payment: { status: 'unpaid' } }
      expect(payment.reload).to be_unpaid
    end

    it '他人は更新できない' do
      login_as(other_user)
      patch team_event_payment_path(team, event, payment), params: { payment: { status: 'paid' } }
      expect(response).to have_http_status(:not_found)
    end

    context '不正なstatusを送った場合' do
      before do
        login_as(owner)
        patch team_event_payment_path(team, event, payment), params: { payment: { status: 'garbage' } }
      end

      it '拒否されリダイレクトされる' do
        expect(response).to redirect_to(team_event_path(team, event))
      end

      it '支払い状況は変わらない' do
        expect(payment.reload).to be_unpaid
      end
    end
  end
end
