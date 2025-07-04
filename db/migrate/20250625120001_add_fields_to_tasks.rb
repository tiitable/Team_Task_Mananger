class AddFieldsToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :priority, :integer, default: 1
    add_column :tasks, :due_date, :datetime
    
    add_index :tasks, :priority
    add_index :tasks, :due_date
  end
end