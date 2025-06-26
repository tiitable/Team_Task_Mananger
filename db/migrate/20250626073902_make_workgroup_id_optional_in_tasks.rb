class MakeWorkgroupIdOptionalInTasks < ActiveRecord::Migration[8.0]
  def change
    change_column_null :tasks, :workgroup_id, true
  end
end
