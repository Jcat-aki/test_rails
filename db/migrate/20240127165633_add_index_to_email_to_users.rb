# frozen_string_literal: true

class AddIndexToEmailToUsers < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :email, unique: true
  end
end
