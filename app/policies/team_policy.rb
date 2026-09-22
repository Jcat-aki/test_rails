# frozen_string_literal: true

# 「Teamおよびその配下(TeamMember/Event/Payment等)へのアクセスは、
#  そのTeamのownerであるユーザーにしか許可しない」という認可ルールを一箇所にまとめる。
class TeamPolicy
  def initialize(user)
    @user = user
  end

  # ownerでなければActiveRecord::RecordNotFoundを投げる（Rails既定で404になる）
  def find!(team_id)
    @user.teams.find(team_id)
  end
end
