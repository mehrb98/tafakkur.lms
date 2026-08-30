# frozen_string_literal: true

FactoryBot.define do
    factory :school_class do
        school
        academic_year { association :academic_year, school: school }
        sequence(:name) { |n| "Grade #{n}" }
        grade_level { 5 }
    end

    factory :section do
        school { school_class.school }
        school_class
        sequence(:name) { |n| "Section #{('A'..'Z').to_a[n % 26]}#{n}" }
        capacity { 30 }
    end

    factory :subject do
        school
        sequence(:name) { |n| "Subject #{n}" }
        sequence(:code) { |n| "SUB#{n.to_s.rjust(3, '0')}" }
    end

    factory :subject_assignment do
        school
        teacher { association :teacher, school: school }
        subject { association :subject, school: school }
        section { association :section, school_class: association(:school_class, school: school) }
        semester do
            association :semester,
                        academic_year: section.school_class.academic_year
        end
    end

    factory :enrollment do
        school { student.school }
        student
        section { association :section, school_class: association(:school_class, school: student.school) }
        academic_year { section.school_class.academic_year }
        status { "active" }
        enrolled_on { Date.new(2026, 9, 1) }
    end
end
