# frozen_string_literal: true

json.id student.id
json.student_code student.student_code
json.date_of_birth student.date_of_birth
json.gender student.gender
json.address student.address
json.admission_date student.admission_date
json.user do
    json.partial! "api/v1/shared/user", user: student.user
end
