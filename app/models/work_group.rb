class WorkGroup < ApplicationRecord
  belongs_to :admin, class_name: 'User'
  has_many :user_workgroups, class_name: 'UserWorkgroup', dependent: :destroy
  has_many :users, through: :user_workgroups
  has_many :tasks, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }
  # validates :admin, presence: { message: "is required" }

  scope :for_user, ->(user) { joins(:user_workgroups).where(user_workgroups: { user: user }) }

  def add_user(user)
    users << user unless users.include?(user)
  end

  def remove_user(user)
    users.delete(user)
  end


end