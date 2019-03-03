FactoryBot.define do
  factory :recipe do
    title { Faker::Food.dish }
    description { Faker::Food.description }
    user
  end
end
