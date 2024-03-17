# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :user_name, null: false, comment: 'ユーザ名'
      t.string :email, null: false, comment: 'メールアドレス'
      t.string :password_digest, null: false, comment: '暗号化されたパスワード'

      t.timestamps
    end
  end
end
