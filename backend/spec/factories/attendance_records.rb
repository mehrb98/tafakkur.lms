# frozen_string_literal: true

FactoryBot.define do
    factory :attendance_record do
        school { student.school }
        student
        section { association :section, school_class: association(:school_class, school: student.school) }
        recorded_by { association :user, :teacher, school: student.school }
        date { Date.new(2026, 9, 15) }
        status { "present" }
    end
end
