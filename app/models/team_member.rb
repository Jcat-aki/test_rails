# frozen_string_literal: true

# == Schema Information
#
# Table name: team_members
#
#  id                                                    :bigint           not null, primary key
#  email(任意。出欠URL通知等に将来利用)                  :string(255)
#  name(メンバー表示名)                                  :string(255)      not null
#  status(0: active, 1: inactive)                        :integer          default("active"), not null
#  created_at                                            :datetime         not null
#  updated_at                                            :datetime         not null
#  team_id                                               :bigint           not null
#  user_id(アプリのログインユーザーと紐付く場合のみ設定) :bigint
#
# Indexes
#
#  index_team_members_on_team_id  (team_id)
#  index_team_members_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_id => users.id)
#
class TeamMember < ApplicationRecord
  belongs_to :team
  belongs_to :user, optional: true

  enum :status, { active: 0, inactive: 1 }

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
