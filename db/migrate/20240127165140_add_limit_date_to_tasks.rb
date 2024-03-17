# frozen_string_literal: true

class AddLimitDateToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :limit_date, :date, after: :title, comment: '終了期日'
  end
end
