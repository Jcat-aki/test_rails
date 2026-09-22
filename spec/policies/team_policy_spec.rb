# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamPolicy do
  let(:owner) { User.create!(user_name: '幹事太郎', email: 'owner@example.com', password: 'password') }
  let(:other_user) { User.create!(user_name: '別の幹事', email: 'other@example.com', password: 'password') }
  let!(:team) { Team.create!(owner:, name: 'フットサルクラブ') }

  describe '#find!' do
    it 'ownerなら見つかる' do
      expect(described_class.new(owner).find!(team.id)).to eq(team)
    end

    it 'owner以外はActiveRecord::RecordNotFound' do
      expect { described_class.new(other_user).find!(team.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
