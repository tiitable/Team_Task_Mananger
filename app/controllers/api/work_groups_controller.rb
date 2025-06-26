class Api::WorkGroupsController < ApplicationController
  before_action :authenticate_user!
  protect_from_forgery with: :null_session
  respond_to :json

  def index
    # Get work groups where user is admin or member
    admin_groups = current_user.owned_work_groups.includes(:users, :tasks)
    member_groups = current_user.work_groups.includes(:admin, :users, :tasks)
    
    all_groups = (admin_groups + member_groups).uniq
    
    work_groups_data = all_groups.map do |wg|
      {
        id: wg.id,
        name: wg.name,
        description: wg.description,
        admin: {
          id: wg.admin.id,
          nickname: wg.admin.nickname,
          email: wg.admin.email
        },
        user_count: wg.users.count,
        task_count: wg.tasks.count,
        created_at: wg.created_at,
        user_role: current_user.owned_work_groups.include?(wg) ? 'admin' : 'member'
      }
    end
    
    render json: {
      status: 'success',
      work_groups: work_groups_data
    }
  end

  def create
    @work_group = WorkGroup.new(work_group_params)
    @work_group.admin_id = current_user.id
    
    if @work_group.save
      render json: {
        status: 'success',
        message: 'Workspace created successfully',
        work_group: {
          id: @work_group.id,
          name: @work_group.name,
          description: @work_group.description,
          admin: {
            id: @work_group.admin.id,
            nickname: @work_group.admin.nickname,
            email: @work_group.admin.email
          },
          user_count: 0,
          task_count: 0,
          created_at: @work_group.created_at
        }
      }, status: :created
    else
      render json: {
        status: 'error',
        message: 'Workspace creation failed',
        errors: @work_group.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def my_workspaces
    # Alias for index - same functionality
    index
  end

  private

  def work_group_params
    params.require(:work_group).permit(:name, :description)
  end
end