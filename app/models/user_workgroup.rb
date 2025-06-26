class UserWorkgroup < ApplicationRecord
  belongs_to :user
  belongs_to :work_group

  validates :user, presence: true
  validates :work_group, presence: true
  validates :user_id, uniqueness: { scope: :work_group_id, message: "is already a member of this workspace" }

  enum :role, { member: 0, moderator: 1, admin: 2 }, default: :member

  scope :by_role, ->(role) { where(role: role) }
  scope :admins, -> { where(role: :admin) }
  scope :moderators, -> { where(role: :moderator) }
end