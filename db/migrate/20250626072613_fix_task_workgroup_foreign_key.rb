class FixTaskWorkgroupForeignKey < ActiveRecord::Migration[8.0]
  def change
    # Remove the incorrect foreign key constraint
    remove_foreign_key :tasks, :workgroups if foreign_key_exists?(:tasks, :workgroups)
    
    # Add the correct foreign key constraint
    add_foreign_key :tasks, :work_groups, column: :workgroup_id
  end
end
