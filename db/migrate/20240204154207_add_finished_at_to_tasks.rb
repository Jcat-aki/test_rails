# frozen_string_literal: true

class AddFinishedAtToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :finished_at, :datetime, comment: '終了日時を格納する'
  end
end
