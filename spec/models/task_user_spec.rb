require 'rails_helper'

RSpec.describe TaskUser, type: :model do
  let(:task) { create(:task) }
  let(:user) { create(:user) }
  let(:task_user) { TaskUser.new(task: task, user: user) }

  it 'taskとuserがあれば有効' do
    expect(task_user).to be_valid
  end

  it 'taskがなければ無効' do
    task_user.task = nil
    expect(task_user).not_to be_valid
  end

  it 'userがなければ無効' do
    task_user.user = nil
    expect(task_user).not_to be_valid
  end

  it 'taskとuserの関係を持てる' do
    task_user.save!
    expect(task_user.task).to eq(task)
    expect(task_user.user).to eq(user)
  end
end
