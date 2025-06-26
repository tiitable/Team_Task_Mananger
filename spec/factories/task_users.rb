FactoryBot.define do
  factory :task_user do
    association :task
    association :user
  end
end
