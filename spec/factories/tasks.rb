FactoryBot.define do
  factory :task do
    title { 'Test Task' }
    description { 'Test Description' }
    category { 'bug' }
    status { 'open' }
    association :owner, factory: :user
    association :workgroup
  end
end
