# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create test users
puts "Creating test users..."

admin_user = User.find_or_create_by(email: 'admin@example.com') do |user|
  user.nickname = '管理者'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

test_user = User.find_or_create_by(email: 'test@example.com') do |user|
  user.nickname = 'テストユーザー'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

developer_user = User.find_or_create_by(email: 'dev@example.com') do |user|
  user.nickname = '開発者'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

puts "Created #{User.count} users"

# Create test work groups
puts "Creating test work groups..."

frontend_team = WorkGroup.find_or_create_by(name: 'フロントエンド開発チーム') do |wg|
  wg.admin = admin_user
  wg.description = 'Vue.js、React、Angular等のフロントエンド技術を使用した開発チーム'
end

backend_team = WorkGroup.find_or_create_by(name: 'バックエンド開発チーム') do |wg|
  wg.admin = admin_user
  wg.description = 'Rails、Node.js、Python等のバックエンド技術を使用した開発チーム'
end

# Add users to work groups
frontend_team.users << test_user unless frontend_team.users.include?(test_user)
frontend_team.users << developer_user unless frontend_team.users.include?(developer_user)

backend_team.users << test_user unless backend_team.users.include?(test_user)
backend_team.users << developer_user unless backend_team.users.include?(developer_user)

puts "Created #{WorkGroup.count} work groups"

# Create test tasks
puts "Creating test tasks..."

Task.find_or_create_by(title: 'ダッシュボードUIの改善', workgroup: frontend_team) do |task|
  task.description = 'ユーザーダッシュボードのレスポンシブデザイン対応とUX改善'
  task.category = 'enhancement'
  task.status = 'in_progress'
  task.priority = 'high'
  task.owner = admin_user
  task.due_date = 1.week.from_now
end

Task.find_or_create_by(title: 'API認証システムの実装', workgroup: backend_team) do |task|
  task.description = 'JWT認証システムの実装とセキュリティ強化'
  task.category = 'feature'
  task.status = 'open'
  task.priority = 'high'
  task.owner = admin_user
  task.due_date = 2.weeks.from_now
end

Task.find_or_create_by(title: 'ユーザーフィードバック分析', workgroup: frontend_team) do |task|
  task.description = 'UI/UXの改善点を特定するためのユーザーフィードバック分析'
  task.category = 'research'
  task.status = 'review'
  task.priority = 'medium'
  task.owner = test_user
  task.due_date = 3.days.from_now
end

Task.find_or_create_by(title: 'データベースパフォーマンス最適化', workgroup: backend_team) do |task|
  task.description = 'クエリ最適化とインデックス追加によるパフォーマンス向上'
  task.category = 'maintenance'
  task.status = 'completed'
  task.priority = 'medium'
  task.owner = developer_user
  task.due_date = 1.week.ago
end

puts "Created #{Task.count} tasks"

puts "Seeding completed successfully!"
puts "Test users created:"
puts "- admin@example.com (password: password123)"
puts "- test@example.com (password: password123)"
puts "- dev@example.com (password: password123)"
