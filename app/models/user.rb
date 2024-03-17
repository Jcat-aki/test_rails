# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                                      :bigint           not null, primary key
#  email(メールアドレス)                   :string(255)      not null
#  password_digest(暗号化されたパスワード) :string(255)      not null
#  user_name(ユーザ名)                     :string(255)      not null
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :user_name, presence: true, length: { minimum: 3 }
end
