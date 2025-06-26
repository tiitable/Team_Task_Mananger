# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_26_073902) do
  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.string "content", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "task_users", force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_task_users_on_task_id"
    t.index ["user_id"], name: "index_task_users_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "status"
    t.string "category"
    t.integer "owner_id", null: false
    t.integer "workgroup_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "priority", default: 1
    t.datetime "due_date"
    t.index ["due_date"], name: "index_tasks_on_due_date"
    t.index ["owner_id"], name: "index_tasks_on_owner_id"
    t.index ["priority"], name: "index_tasks_on_priority"
    t.index ["workgroup_id"], name: "index_tasks_on_workgroup_id"
  end

  create_table "user_workgroups", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "work_group_id", null: false
    t.integer "role", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role"], name: "index_user_workgroups_on_role"
    t.index ["user_id", "work_group_id"], name: "index_user_workgroups_on_user_id_and_work_group_id", unique: true
    t.index ["user_id"], name: "index_user_workgroups_on_user_id"
    t.index ["work_group_id"], name: "index_user_workgroups_on_work_group_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nickname"
    t.string "jti", null: false
    t.text "avatar"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "work_groups", force: :cascade do |t|
    t.string "name", null: false
    t.integer "admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["admin_id"], name: "index_work_groups_on_admin_id"
    t.index ["name"], name: "index_work_groups_on_name", unique: true
  end

  add_foreign_key "posts", "users"
  add_foreign_key "task_users", "tasks"
  add_foreign_key "task_users", "users"
  add_foreign_key "tasks", "users", column: "owner_id"
  add_foreign_key "tasks", "work_groups", column: "workgroup_id"
  add_foreign_key "user_workgroups", "users"
  add_foreign_key "user_workgroups", "work_groups"
  add_foreign_key "work_groups", "users", column: "admin_id"
end
