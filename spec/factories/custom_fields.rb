FactoryBot.define do
  factory :custom_field do
    name { Faker::Lorem.word }
  end
end
