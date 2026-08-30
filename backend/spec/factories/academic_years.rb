# frozen_string_literal: true

FactoryBot.define do
    factory :academic_year do
        school
        sequence(:name) { |n| "20#{20 + n}-20#{21 + n}" }
        start_date { Date.new(2026, 9, 1) }
        end_date { Date.new(2027, 6, 30) }
        is_current { false }
    end

    factory :semester do
        school { academic_year.school }
        academic_year
        sequence(:name) { |n| "Semester #{n}" }
        start_date { academic_year.start_date }
        end_date { academic_year.start_date + 4.months }
    end

    factory :department do
        school
        sequence(:name) { |n| "Department #{n}" }
    end
end
