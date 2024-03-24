# frozen_string_literal: true

namespace :create_japan do
  desc 'Jリーグのチーム名を取得する'
  task teams: :environment do
    url = 'https://www.jleague.jp/club/'
    html = URI.parse(url).read

    doc = Nokogiri::HTML.parse(html)

    # 日本のチームだけなので、全削除
    Team.destroy_all

    create_teams!('#j1Emb', doc, :pro_first)

    create_teams!('#j2Emb', doc, :pro_second)

    create_teams!('#j3Emb', doc, :pro_thrid)
  end
end

def create_teams!(category_id, doc, category)
  doc.at_css(category_id).elements.each do |element|
    Team.create!(name: element.text, country: '日本', category:)
  end
end
