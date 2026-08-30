# frozen_string_literal: true

json.data do
    json.id @enrollment.id
    json.student_id @enrollment.student_id
    json.section_id @enrollment.section_id
    json.academic_year_id @enrollment.academic_year_id
    json.status @enrollment.status
    json.enrolled_on @enrollment.enrolled_on
end
