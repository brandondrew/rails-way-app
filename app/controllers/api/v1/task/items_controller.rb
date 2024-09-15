# frozen_string_literal: true

class API::V1::Task::ItemsController < API::V1::Task::Items::BaseController
  before_action :authenticate_user!
  before_action :require_task_list!
  before_action :set_task_item, except: %i[index create]

  def index
    task_items = Current.task_items

    @task_items =
      case params[:filter]
      when "completed" then task_items.completed.order(completed_at: :desc)
      when "incomplete" then task_items.incomplete.order(created_at: :desc)
      else task_items.order(Arel.sql("task_items.completed_at DESC NULLS FIRST, task_items.created_at DESC"))
      end
  end

  def show
  end

  def create
    @task_item = Current.task_items.new(task_item_params)

    if @task_item.save
      render :show, status: :created, location: task_item_url(@task_item)
    else
      render_json_with_model_errors(@task_item)
    end
  end

  def update
    if @task_item.update(task_item_params)
      render :show, status: :ok, location: task_item_url(@task_item)
    else
      render_json_with_model_errors(@task_item)
    end
  end

  def destroy
    @task_item.destroy!

    head :no_content
  end

  private

  def task_item_params
    params.require(:task_item).permit(:name, :description, :completed)
  end
end
