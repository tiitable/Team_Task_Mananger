require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:owner) { create(:user) }
  let(:workgroup) { create(:workgroup) }
  let(:user) { create(:user) }
  let(:task) { Task.new(title: 'Test Task', description: 'Test Description', category: 'bug', status: 'open', owner: owner, workgroup: workgroup) }

  describe 'バリデーション' do
    it 'title, description, category, status, owner, workgroup があれば有効' do
      expect(task).to be_valid
    end
    it 'titleがなければ無効' do
      task.title = nil
      expect(task).not_to be_valid
    end
    it 'categoryがなければ無効' do
      task.category = nil
      expect(task).not_to be_valid
    end
    it 'statusがなければ無効' do
      task.status = nil
      expect(task).not_to be_valid
    end
  end

  describe '多対多関係' do
    it '複数の関連ユーザーを持てる' do
      task.save!
      task.users << user
      expect(task.users).to include(user)
    end
  end

  describe 'owner関係' do
    it 'ownerがUserである' do
      expect(task.owner).to eq(owner)
    end
  end

  describe 'workgroup関係' do
    it 'workgroupがWorkgroupである' do
      expect(task.workgroup).to eq(workgroup)
    end
  end
end
