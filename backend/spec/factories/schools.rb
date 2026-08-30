# frozen_string_literal: true

FactoryBot.define do
    factory :school do
        name { Faker::Educator.secondary_school }
        sequence(:slug) { |n| "school-#{n}" }
        timezone { "UTC" }
        locale { "en" }
        subscription_status { "active" }
    end
end
