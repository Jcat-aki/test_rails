# frozen_string_literal: true

class TeamMembersController < ApplicationController
  before_action :logged_in_user
  before_action :set_team
  before_action :set_team_member, only: %i[edit update deactivate]

  def new
    @team_member = @team.team_members.new
  end

  def create
    @team_member = @team.team_members.new(team_member_params)

    if @team_member.save
      redirect_to team_path(@team), notice: 'メンバーを登録しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @team_member.update(team_member_params)
      redirect_to team_path(@team), notice: 'メンバー情報を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def deactivate
    @team_member.inactive!
    redirect_to team_path(@team), notice: "#{@team_member.name} を無効化しました"
  end

  private

  # 自分がownerのTeam配下以外は見つからない扱いにする（他人のTeamへのアクセス防止）
  def set_team
    @team = current_user.teams.find(params[:team_id])
  end

  def set_team_member
    @team_member = @team.team_members.find(params[:id])
  end

  def team_member_params
    params.require(:team_member).permit(:name, :email)
  end
end
