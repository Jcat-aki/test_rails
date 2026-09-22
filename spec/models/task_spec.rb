# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id                              :bigint           not null, primary key
#  finished_at(終了日時を格納する) :datetime
#  limit_date(終了期日)            :date
#  title(タスクのタイトル)         :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  assignee_team_member_id         :bigint
#  event_id                        :bigint
#  team_id                         :bigint
#
# Indexes
#
#  index_tasks_on_assignee_team_member_id  (assignee_team_member_id)
#  index_tasks_on_event_id                 (event_id)
#  index_tasks_on_team_id                  (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (assignee_team_member_id => team_members.id)
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (team_id => teams.id)
#
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

  describe 'イベント単位の担当タスクとしての利用' do
    let(:owner) { User.create!(user_name: '幹事太郎', email: 'kanji@example.com', password: 'password') }
    let(:team) { Team.create!(owner:, name: 'フットサルクラブ') }
    let!(:member) { team.team_members.create!(name: '田中') }
    let(:event) { team.events.create!(title: '練習試合', starts_at: Time.zone.now) }

    it 'team/event/assignee_team_memberを指定して作成できる' do
      task = described_class.create!(title: 'ボール準備', team:, event:, assignee_team_member: member)

      expect(task).to be_persisted
    end

    it 'event/assignee_team_memberは任意（無くても作成できる）' do
      task = described_class.new(title: 'ボール準備')
      expect(task).to be_valid
    end
  end
end
