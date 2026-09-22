# frozen_string_literal: true

# 自分がownerのTeam配下のリソースしか見つからない扱いにする（他人のTeamへのアクセス防止）。
# 呼び出し側で `before_action :set_team, only: [...]` を自分で宣言すること
# （対象アクションはコントローラごとに異なるため、ここでは強制しない）。
module TeamScoped
  extend ActiveSupport::Concern

  private

  def set_team
    @team = TeamPolicy.new(current_user).find!(params[:team_id] || params[:id])
  end
end
