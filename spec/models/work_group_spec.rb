require 'rails_helper'

RSpec.describe Workgroup, type: :model do
  before { @user = create(:user) }
  let(:workgroup) { 'Test Workgroup' }
  let(:user_id) { @user.id }

  context '正常' do
    it '有効なファクトリを持つ' do
      expect(workgroup.valid?).to be(true)
    end
  end

  context '異常' do

    describe 'バリデーション' do
      it '名前があれば有効' do
        expect(workgroup).to be_valid
      end

      it '名前がなければ無効' do
        workgroup.name = nil
        expect(workgroup).not_to be_valid
      end

      it '名前が重複していれば無効' do
        create(:workgroup, name: '重複名')
        dup = build(:workgroup, name: '重複名')
        expect(dup).not_to be_valid
      end

      it '管理者がなければ無効' do
        workgroup.admin = nil
        expect(workgroup).not_to be_valid
      end
    end
end
