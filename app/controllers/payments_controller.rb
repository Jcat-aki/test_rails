# frozen_string_literal: true

class PaymentsController < ApplicationController
  include TeamScoped

  before_action :logged_in_user
  before_action :set_team
  before_action :set_event
  before_action :set_payment

  def update
    case payment_params[:status]
    when 'paid'
      @payment.mark_as_paid!
    when 'unpaid'
      @payment.mark_as_unpaid!
    else
      return redirect_to team_event_path(@team, @event), alert: '不正な支払い状況です'
    end

    redirect_to team_event_path(@team, @event), notice: '支払い状況を更新しました'
  end

  private

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
