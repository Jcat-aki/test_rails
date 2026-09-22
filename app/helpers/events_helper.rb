# frozen_string_literal: true

module EventsHelper
  # 幹事がそのままLINEに貼れる、未回答者へのリマインドテキストを組み立てる
  def event_reminder_text(event, unanswered_attendances)
    return '' if unanswered_attendances.blank?

    lines = unanswered_attendances.map do |attendance|
      "#{attendance.team_member.name}：#{attendance_response_url(attendance.public_token)}"
    end

    "#{l(event.starts_at, format: :date)}の#{event.title}、まだ出欠未回答です！\n#{lines.join("\n")}"
  end
end
