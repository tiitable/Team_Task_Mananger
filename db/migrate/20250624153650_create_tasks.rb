class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :description
      t.string :status
      t.string :category
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.references :work_group, null: false, foreign_key: true
      t.timestamps
    end
  end
end
