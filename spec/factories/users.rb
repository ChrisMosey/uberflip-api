FactoryBot.define do
  factory :user do
    first_name { "Test" }
    last_name { "Testerson" }
    email { "test@example.com" }
    hourly_wage { 12.50 }
    sin { "130692544" }
  end
end
