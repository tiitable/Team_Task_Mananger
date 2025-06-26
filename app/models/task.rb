class Task < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  belongs_to :workgroup, class_name: 'WorkGroup', foreign_key: 'workgroup_id', optional: true
  has_many :task_users, dependent: :destroy
  has_many :users, through: :task_users

  validates :category, presence: true
  validates :status, presence: true
  validates :title, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 2000 }

  enum :status, { 
    open: 0, 
    in_progress: 1, 
    review: 2, 
    completed: 3, 
    archived: 4 
  }, default: :open

  enum :category, { 
    feature: 0, 
    bug: 1, 
    enhancement: 2, 
    documentation: 3, 
    research: 4, 
    maintenance: 5 
  }, default: :feature

  enum :priority, { 
    low: 0, 
    medium: 1, 
    high: 2, 
    urgent: 3 
  }, default: :medium

  scope :by_status, ->(status) { where(status: status) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :assigned_to, ->(user) { joins(:task_users).where(task_users: { user: user }) }
  scope :owned_by, ->(user) { where(owner: user) }
  scope :in_workspace, ->(workgroup) { where(workgroup: workgroup) }
  scope :search, ->(query) { where("title ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%") }
  scope :due_soon, -> { where(due_date: Date.current..1.week.from_now) }
  scope :overdue, -> { where("due_date < ?", Date.current) }

  def overdue?
    due_date.present? && due_date < Date.current && !completed?
  end

  def due_soon?
    due_date.present? && due_date <= 1.week.from_now && due_date >= Date.current
  end

  def assigned_users_count
    users.count
  end

  def progress_percentage
    case status
    when 'open'
      0
    when 'in_progress'
      50
    when 'review'
      75
    when 'completed'
      100
    when 'archived'
      100
    else
      0
    end
  end
end
