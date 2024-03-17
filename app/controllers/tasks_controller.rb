# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :logged_in_user

  def index
    @tasks = Task.all.order(:limit_date)
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.save!
    redirect_to tasks_path
  rescue StandardError => e
    Rails.logger.error(e)
    render :new
  end

  def edit
    @task = Task.find(params[:id])
    @limit_date = @task.limit_date.presence || Time.zone.today
  end

  def update
    @task = Task.find(params[:id])
    @task.update!(task_params)
    redirect_to tasks_url
  rescue StandardError => e
    Rails.logger.error(e)
    render :edit
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    redirect_to tasks_url
  end

  def finished
    @task = Task.find(params[:id])
    @task.finished_at = Time.current
    @task.save!
    redirect_to tasks_url
  rescue StandardError => e
    Rails.logger.error(e)
    redirect_to tasks_url
  end

  private

  def task_params
    params.require(:task).permit(:title, :limit_date)
  end
end
