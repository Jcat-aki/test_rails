# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :logged_in_user
  before_action :set_team
  before_action :set_event, only: %i[show edit update]

  def index
    @events = @team.events.order(starts_at: :desc)
  end

  def show
    @summary = @event.attendance_summary
    @unanswered_attendances = @event.unanswered_attendances
  end

  def new
    @event = @team.events.new(starts_at: Time.zone.now)
  end

  def create
    @event = @team.events.new(event_params)

    if @event.save
      redirect_to team_event_path(@team, @event), notice: 'イベントを作成しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @event.update(event_params)
      redirect_to team_event_path(@team, @event), notice: 'イベントを更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # 自分がownerのTeam配下以外は見つからない扱いにする（他人のTeamへのアクセス防止）
  def set_team
    @team = current_user.teams.find(params[:team_id])
  end

  def set_event
    @event = @team.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :starts_at, :ends_at, :location, :participation_fee, :note)
  end
end
