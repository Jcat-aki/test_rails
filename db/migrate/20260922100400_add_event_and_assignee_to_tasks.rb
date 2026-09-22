# frozen_string_literal: true

class AddEventAndAssigneeToTasks < ActiveRecord::Migration[7.1]
  def change
    add_reference :tasks, :event, foreign_key: true
    add_reference :tasks, :assignee_team_member, foreign_key: { to_table: :team_members }
  end
end
