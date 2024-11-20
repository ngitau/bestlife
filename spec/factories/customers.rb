FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    phone_number { Faker::PhoneNumber.cell_phone }
  end
end
