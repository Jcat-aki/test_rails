# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validation' do
    context '適切な期日設定の場合' do
      let!(:task) { described_class.create!(title: 'テストのススメ', limit_date: Time.zone.today) }

      it 'タイトルのみ変更しても何も起きないこと' do
        travel_to Time.zone.now.tomorrow do
          task.title = 'テストしたかった..'
          expect(task).to be_valid
        end
      end

      it '日付を前日以前に変更できないこと' do
        task.limit_date = Time.zone.now.yesterday.to_date
        expect(task).to be_invalid
      end
    end
  end
end
