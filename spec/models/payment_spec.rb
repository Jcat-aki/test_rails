# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                         :bigint           not null, primary key
#  amount(参加費（円）)       :integer          not null
#  paid_at                    :datetime
#  status(0: unpaid, 1: paid) :integer          default("unpaid"), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  event_id                   :bigint           not null
#  team_member_id             :bigint           not null
#
# Indexes
#
#  index_payments_on_event_id                     (event_id)
#  index_payments_on_event_id_and_team_member_id  (event_id,team_member_id) UNIQUE
#  index_payments_on_team_member_id               (team_member_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (team_member_id => team_members.id)
#
require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:owner) { User.create!(user_name: '幹事太郎', email: 'kanji@example.com', password: 'password') }
  let(:team) { Team.create!(owner:, name: 'フットサルクラブ') }
  let!(:member) { team.team_members.create!(name: '田中') }
  let(:event) { team.events.create!(title: '練習試合', starts_at: Time.zone.now, participation_fee: 1500) }

  describe 'validation' do
    it 'amountが無いとinvalid' do
      payment = event.payments.new(team_member: member, amount: nil)
      expect(payment).to be_invalid
    end

    it '同じevent×team_memberの組は重複できない' do
      event.payments.create!(team_member: member, amount: 1500)
      duplicate = event.payments.new(team_member: member, amount: 1500)
      expect(duplicate).to be_invalid
    end
  end

  describe '#mark_as_paid!' do
    let(:payment) { event.payments.create!(team_member: member, amount: 1500) }

    before { payment.mark_as_paid! }

    it '支払済みになる' do
      expect(payment.reload).to be_paid
    end

    it 'paid_atが設定される' do
      expect(payment.paid_at).to be_present
    end
  end

  describe '#mark_as_unpaid!' do
    let(:payment) { event.payments.create!(team_member: member, amount: 1500) }

    before do
      payment.mark_as_paid!
      payment.mark_as_unpaid!
    end

    it '未払いに戻る' do
      expect(payment.reload).to be_unpaid
    end

    it 'paid_atがクリアされる' do
      expect(payment.paid_at).to be_nil
    end
  end
end
