FactoryBot.define do
  factory :timesheet do
    user { create :user }
  end
end
