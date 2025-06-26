class Api::TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [:show, :update, :destroy, :assign_users, :unassign_user]
  before_action :set_work_group, only: [:index, :create]
  before_action :ensure_workspace_member, only: [:index, :create]
  before_action :ensure_task_access, only: [:show, :update, :destroy, :assign_users, :unassign_user]
  protect_from_forgery with: :null_session
  respond_to :json

  def index
    @tasks = @work_group.tasks.includes(:owner, :users)
    
    # Filter by status if provided
    @tasks = @tasks.where(status: params[:status]) if params[:status].present?
    
    # Filter by category if provided
    @tasks = @tasks.where(category: params[:category]) if params[:category].present?
    
    # Filter by assigned user
    @tasks = @tasks.joins(:task_users).where(task_users: { user_id: params[:assigned_to] }) if params[:assigned_to].present?
    
    # Search by title or description
    if params[:search].present?
      @tasks = @tasks.where("title ILIKE ? OR description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    @tasks = @tasks.order(created_at: :desc)
    
    render json: {
      status: 'success',
      tasks: @tasks.map { |task| task_response(task) },
      total_count: @tasks.count
    }
  end

  def show
    render json: {
      status: 'success',
      task: task_response(@task, include_details: true)
    }
  end

  def create
    if @work_group
      @task = @work_group.tasks.build(task_params)
    else
      # Create task without work group
      @task = Task.new(task_params)
    end
    @task.owner = current_user
    
    if @task.save
      # Assign users if provided
      if params[:user_ids].present?
        assign_users_to_task(@task, params[:user_ids])
      end
      
      render json: {
        status: 'success',
        message: 'Task created successfully',
        task: task_response(@task, include_details: true)
      }, status: :created
    else
      render json: {
        status: 'error',
        message: 'Task creation failed',
        errors: @task.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      # Update assigned users if provided
      if params[:user_ids].present?
        @task.task_users.destroy_all
        assign_users_to_task(@task, params[:user_ids])
      end
      
      render json: {
        status: 'success',
        message: 'Task updated successfully',
        task: task_response(@task, include_details: true)
      }
    else
      render json: {
        status: 'error',
        message: 'Task update failed',
        errors: @task.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @task.destroy
      render json: {
        status: 'success',
        message: 'Task deleted successfully'
      }
    else
      render json: {
        status: 'error',
        message: 'Failed to delete task'
      }, status: :unprocessable_entity
    end
  end

  def my_tasks
    # Tasks assigned to current user
    assigned_tasks = current_user.tasks.includes(:owner, :workgroup, :users)
    
    # Tasks owned by current user
    owned_tasks = current_user.owned_tasks.includes(:owner, :workgroup, :users)
    
    render json: {
      status: 'success',
      assigned_tasks: assigned_tasks.map { |task| task_response(task) },
      owned_tasks: owned_tasks.map { |task| task_response(task) }
    }
  end

  private

  def set_task
    @task = Task.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: 'Task not found'
    }, status: :not_found
  end

  def set_work_group
    @work_group = WorkGroup.find(params[:work_group_id]) if params[:work_group_id]
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: 'Workspace not found'
    }, status: :not_found
  end

  def ensure_workspace_member
    return unless @work_group
    
    unless current_user.workspace_member?(@work_group) || current_user.workspace_admin?(@work_group)
      render json: {
        status: 'error',
        message: 'Access denied to this workspace'
      }, status: :forbidden
    end
  end

  def ensure_task_access
    # If task has no workgroup, only owner and assigned users can access
    if @task.workgroup.nil?
      unless @task.users.include?(current_user) || @task.owner == current_user
        render json: {
          status: 'error',
          message: 'Access denied to this task'
        }, status: :forbidden
      end
    else
      # Original workgroup-based access control
      unless current_user.workspace_member?(@task.workgroup) || 
             current_user.workspace_admin?(@task.workgroup) ||
             @task.users.include?(current_user) ||
             @task.owner == current_user
        render json: {
          status: 'error',
          message: 'Access denied to this task'
        }, status: :forbidden
      end
    end
  end

  def task_params
    params.require(:task).permit(:title, :description, :category, :status, :priority, :due_date)
  end

  def assign_users_to_task(task, user_ids)
    user_ids.each do |user_id|
      task.task_users.create(user_id: user_id)
    end
  end

  def task_response(task, include_details: false)
    response = {
      id: task.id,
      title: task.title,
      description: task.description,
      category: task.category,
      status: task.status,
      priority: task.priority,
      due_date: task.due_date,
      owner: {
        id: task.owner.id,
        nickname: task.owner.nickname,
        email: task.owner.email
      },
      workgroup: task.workgroup ? {
        id: task.workgroup.id,
        name: task.workgroup.name
      } : nil,
      assigned_users_count: task.users.count,
      created_at: task.created_at,
      updated_at: task.updated_at
    }

    if include_details
      response[:assigned_users] = task.users.map do |user|
        {
          id: user.id,
          nickname: user.nickname,
          email: user.email
        }
      end
    end

    response
  end
end