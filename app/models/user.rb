class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  has_many :posts, dependent: :destroy
  has_many :user_workgroups, class_name: 'UserWorkgroup', dependent: :destroy
  has_many :work_groups, through: :user_workgroups
  has_many :owned_work_groups, class_name: 'WorkGroup', foreign_key: 'admin_id', dependent: :destroy
  has_many :owned_tasks, class_name: 'Task', foreign_key: 'owner_id', dependent: :destroy
  has_many :task_users, dependent: :destroy
  has_many :tasks, through: :task_users

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :nickname, presence: true, length: { maximum: 20 }
  
  # Avatar validation
  validate :avatar_format, if: -> { avatar.present? && avatar_changed? }

  def full_name
    nickname
  end

  def workspace_member?(work_group)
    work_groups.include?(work_group)
  end

  def workspace_admin?(work_group)
    owned_work_groups.include?(work_group)
  end

  # Avatar methods
  def avatar_url
    return avatar if avatar.present? && avatar.start_with?('data:image')
    nil
  end

  def has_avatar?
    avatar.present?
  end

  private

  def avatar_format
    return unless avatar.present?
    
    unless avatar.start_with?('data:image/')
      errors.add(:avatar, 'must be a valid image in base64 format')
      return
    end
    
    # Check file size (limit to 5MB when decoded to be more lenient)
    begin
      # More accurate base64 size calculation
      base64_data = avatar.split(',')[1] # Remove data:image/...;base64, prefix
      if base64_data
        decoded_size = (base64_data.length * 3) / 4
        if decoded_size > 5.megabytes
          errors.add(:avatar, 'file size must be less than 5MB')
        end
      end
    rescue => e
      Rails.logger.error "Avatar validation error: #{e.message}"
      # Don't fail validation for size calculation errors
    end
  end
end
