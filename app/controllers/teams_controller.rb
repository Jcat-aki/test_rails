# frozen_string_literal: true

class TeamsController < ApplicationController
  before_action :logged_in_user
  before_action :set_team, only: %i[show edit update]

  def index
    @teams = current_user.teams.order(:name)
  end

  def show
    @team_members = @team.team_members.order(:name)
  end

  def new
    @team = Team.new
  end

  def create
    @team = current_user.teams.new(team_params)

    if @team.save
      redirect_to team_path(@team), notice: 'チームを作成しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @team.update(team_params)
      redirect_to team_path(@team), notice: 'チーム情報を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # 自分がownerのTeam以外は見つからない扱いにする（他人のTeamへのアクセス防止）
  def set_team
    @team = current_user.teams.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
