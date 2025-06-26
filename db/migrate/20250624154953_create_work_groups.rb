class CreateWorkGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :work_groups do |t|
      t.string :name, null: false
      t.references :admin, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
    
    add_index :work_groups, :name, unique: true
  end
end
