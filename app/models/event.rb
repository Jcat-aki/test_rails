# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                                                   :bigint           not null, primary key
#  ends_at                                              :datetime
#  location                                             :string(255)
#  note                                                 :text(65535)
#  participation_fee(参加費（円）。nilの場合は費用なし) :integer
#  starts_at                                            :datetime         not null
#  title(イベント名（練習・試合など）)                  :string(255)      not null
#  created_at                                           :datetime         not null
#  updated_at                                           :datetime         not null
#  team_id                                              :bigint           not null
#
# Indexes
#
#  index_events_on_team_id  (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#
class Event < ApplicationRecord
  belongs_to :team

  has_many :attendances, dependent: :destroy
  has_many :tasks, dependent: :nullify

  validates :title, presence: true, length: { maximum: 200 }
  validates :starts_at, presence: true

  after_create :build_attendances_for_active_members

  def attendance_summary
    counts = attendances.group(:status).count
    Attendance.statuses.keys.index_with { |status| counts[status] || 0 }.symbolize_keys
  end

  def unanswered_attendances
    attendances.unanswered.includes(:team_member)
  end

  private

  def build_attendances_for_active_members
    team.team_members.active.find_each do |member|
      attendances.create!(team_member: member)
    end
  end
end
