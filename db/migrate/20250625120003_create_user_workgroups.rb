class CreateUserWorkgroups < ActiveRecord::Migration[8.0]
  def change
    create_table :user_workgroups do |t|
      t.references :user, null: false, foreign_key: true
      t.references :work_group, null: false, foreign_key: true
      t.integer :role, default: 0
      
      t.timestamps
    end

    add_index :user_workgroups, [:user_id, :work_group_id], unique: true
    add_index :user_workgroups, :role
  end
end