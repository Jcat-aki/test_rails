# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id                             :bigint           not null, primary key
#  category(所属チームのカテゴリ) :integer          default(0), not null
#  country(国名)                  :string(255)      not null
#  name(チーム名)                 :string(255)      not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
class Team < ApplicationRecord
  # 海外など含めると色々と面倒なので、1~3部と、アマチュア一部という日本の分け方を採用してます（正しいかは不明）
  enum :category, { pro_first: 0, pro_second: 1, pro_thrid: 2, ama_first: 10 }
end
