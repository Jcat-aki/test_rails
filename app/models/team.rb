# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id                               :bigint           not null, primary key
#  name(チーム名)                   :string(255)      not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  owner_id(チーム作成者(users.id)) :bigint           not null
#
# Indexes
#
#  index_teams_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
class Team < ApplicationRecord
  belongs_to :owner, class_name: 'User', inverse_of: :teams

  has_many :team_members, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
end
