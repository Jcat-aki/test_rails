# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :logged_in_user
  before_action :set_team
  before_action :set_event
  before_action :set_payment

  def update
    if payment_params[:status] == 'paid'
      @payment.mark_as_paid!
    else
      @payment.mark_as_unpaid!
    end

    redirect_to team_event_path(@team, @event), notice: '支払い状況を更新しました'
  end

  private

  # 自分がownerのTeam配下以外は見つからない扱いにする（他人のTeamへのアクセス防止）
  def set_team
    @team = current_user.teams.find(params[:team_id])
  end

  def set_event
    @event = @team.events.find(params[:event_id])
  end

  def set_payment
    @payment = @event.payments.find(params[:id])
  end

  def payment_params
    params.require(:payment).permit(:status)
  end
end
