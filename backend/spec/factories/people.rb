# frozen_string_literal: true

FactoryBot.define do
    factory :teacher do
        school
        user { association :user, :teacher, school: school }
        sequence(:employee_code) { |n| "EMP#{n.to_s.rjust(4, '0')}" }
        specialization { "Mathematics" }
        hire_date { Date.new(2024, 9, 1) }
    end

    factory :student do
        school
        user { association :user, :student, school: school }
        sequence(:student_code) { |n| "STU#{n.to_s.rjust(4, '0')}" }
        date_of_birth { Date.new(2012, 5, 10) }
        gender { "female" }
        admission_date { Date.new(2024, 9, 1) }
    end

    factory :parent do
        school
        user { association :user, :parent, school: school }
        occupation { "Engineer" }
    end

    factory :parent_student do
        parent
        student { association :student, school: parent.school }
        school { parent.school }
        relationship { "father" }
    end
end
