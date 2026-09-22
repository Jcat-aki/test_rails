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
class Task < ApplicationRecord
  # 200 文字以上入れさせる必要なし
  validates :title, length: { in: 1..200 }
  # 期日は本日以降以外許さない
  validates :limit_date, comparison: { greater_than_or_equal_to: Time.zone.today }, allow_blank: true, on: :create

  validates_with ::TaskValidator, fields: [:limit_date], if: :persisted?

  # タスクに対してチームは一つしかアサインできないようにする
  belongs_to :team, optional: true
  # イベント単位の担当タスク（ボール・審判等）として使う場合のみ設定
  belongs_to :event, optional: true
  belongs_to :assignee_team_member, class_name: 'TeamMember', optional: true, inverse_of: :assigned_tasks
end
