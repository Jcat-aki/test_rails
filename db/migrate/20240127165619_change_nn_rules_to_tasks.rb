# frozen_string_literal: true

class ChangeNnRulesToTasks < ActiveRecord::Migration[7.1]
  def up
    change_column :tasks, :title, :string, null: false, comment: 'タスクのタイトル'
  end

  def down
    change_column :tasks, :title, :string
  end
end
