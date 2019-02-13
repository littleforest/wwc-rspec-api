# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    username { 'MyString' }
    password { 'supersecret' }
  end
end
