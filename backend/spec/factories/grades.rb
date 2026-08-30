# frozen_string_literal: true

FactoryBot.define do
    factory :grade do
        school { student.school }
        student
        subject { association :subject, school: student.school }
        semester do
            association :semester,
                        academic_year: association(:academic_year, school: student.school)
        end
        teacher { association :teacher, school: student.school }
        grade_type { "quiz" }
        value { 85 }
        max_value { 100 }
        graded_on { Date.new(2026, 10, 1) }
    end
end
