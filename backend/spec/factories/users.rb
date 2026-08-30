# frozen_string_literal: true

FactoryBot.define do
    factory :user do
        school
        sequence(:email) { |n| "user#{n}@example.com" }
        password { "SecurePassword123" }
        first_name { Faker::Name.first_name }
        last_name { Faker::Name.last_name }
        role { "admin" }
        confirmed_at { Time.current }

        trait :admin do
            role { "admin" }
        end

        trait :teacher do
            role { "teacher" }
        end

        trait :student do
            role { "student" }
        end

        trait :parent do
            role { "parent" }
        end

        trait :unconfirmed do
            confirmed_at { nil }
        end
    end
end
