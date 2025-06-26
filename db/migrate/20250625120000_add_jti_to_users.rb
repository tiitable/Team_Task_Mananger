class AddJtiToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :jti, :string
    
    # Generate JTI for existing users
    User.reset_column_information
    User.find_each do |user|
      user.update_column(:jti, SecureRandom.uuid)
    end
    
    # Now make it non-null
    change_column_null :users, :jti, false
    add_index :users, :jti, unique: true
  end
end