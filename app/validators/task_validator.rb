# frozen_string_literal: true

class TaskValidator < ActiveModel::Validator
  def validate(record)
    # 空の場合は、チェックしない
    return if record.limit_date.blank?
    return if record.limit_date_in_database <= record.limit_date

    record.errors.add(:base, '期日を戻すことはできません')
  end
end
