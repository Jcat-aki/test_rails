# frozen_string_literal: true

# == Schema Information
#
# Table name: attendances
#
#  id                                                            :bigint           not null, primary key
#  comment                                                       :text(65535)
#  public_token(ログイン不要の回答用URLに使う推測困難なトークン) :string(255)      not null
#  responded_at                                                  :datetime
#  status(0: unanswered, 1: attending, 2: absent, 3: undecided)  :integer          default("unanswered"), not null
#  created_at                                                    :datetime         not null
#  updated_at                                                    :datetime         not null
#  event_id                                                      :bigint           not null
#  team_member_id                                                :bigint           not null
#
# Indexes
#
#  index_attendances_on_event_id                     (event_id)
#  index_attendances_on_event_id_and_team_member_id  (event_id,team_member_id) UNIQUE
#  index_attendances_on_public_token                 (public_token) UNIQUE
#  index_attendances_on_team_member_id               (team_member_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (team_member_id => team_members.id)
#
class Attendance < ApplicationRecord
  belongs_to :event
  belongs_to :team_member

  enum :status, { unanswered: 0, attending: 1, absent: 2, undecided: 3 }

  validates :team_member_id, uniqueness: { scope: :event_id }
  validates :public_token, presence: true, uniqueness: true

  before_validation :generate_public_token, on: :create
  after_save :create_payment_if_attending

  # 公開URL経由で許可する更新は status / comment のみ
  def respond!(status:, comment: nil)
    update!(status:, comment:, responded_at: Time.current)
  end

  private

  # 「参加」に回答し、かつイベントに参加費が設定されている場合のみPaymentを作る
  # （不参加/未定に変わっても、一度作られたPaymentは幹事の記録として残す）
  def create_payment_if_attending
    return unless saved_change_to_status? && attending?
    return if event.participation_fee.blank?

    Payment.find_or_create_by!(event:, team_member:) do |payment|
      payment.amount = event.participation_fee
    end
  end

  def generate_public_token
    self.public_token ||= loop do
      token = SecureRandom.urlsafe_base64(16)
      break token unless self.class.exists?(public_token: token)
    end
  end
end
