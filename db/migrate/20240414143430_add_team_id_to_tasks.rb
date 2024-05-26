# frozen_string_literal: true

class AddTeamIdToTasks < ActiveRecord::Migration[7.1]
  def change
    add_reference :tasks, :team, foreign_key: true
  end
end
