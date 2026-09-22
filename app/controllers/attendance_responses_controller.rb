# frozen_string_literal: true

# ログイン不要の公開画面。public_token の一致だけを入口にし、
# 許可する操作はそのAttendance自身の閲覧・回答更新のみ（他のAttendanceやTeam情報は一切見せない）。
class AttendanceResponsesController < ApplicationController
  before_action :set_attendance

  def show; end

  def update
    @attendance.respond!(status: attendance_params[:status], comment: attendance_params[:comment])
    redirect_to attendance_response_path(@attendance.public_token), notice: '回答を保存しました'
  rescue ActiveRecord::RecordInvalid
    render :show, status: :unprocessable_entity
  end

  private

  def set_attendance
    @attendance = Attendance.find_by!(public_token: params[:public_token])
  end

  def attendance_params
    params.require(:attendance).permit(:status, :comment)
  end
end
