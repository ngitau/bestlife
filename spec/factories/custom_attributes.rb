FactoryBot.define do
  factory :custom_attribute do
    key { Faker::Lorem.word }
    value { Faker::Lorem.sentence }

    factory :custom_attribute_for_customer do
      association :attributable, factory: :customer
    end
  end
end
