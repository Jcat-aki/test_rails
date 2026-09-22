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
class Payment < ApplicationRecord
  belongs_to :event
  belongs_to :team_member

  enum :status, { unpaid: 0, paid: 1 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :team_member_id, uniqueness: { scope: :event_id }

  def mark_as_paid!
    update!(status: :paid, paid_at: Time.current)
  end

  def mark_as_unpaid!
    update!(status: :unpaid, paid_at: nil)
  end
end
