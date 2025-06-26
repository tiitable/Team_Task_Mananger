class AddDescriptionToWorkGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :work_groups, :description, :text
  end
end
