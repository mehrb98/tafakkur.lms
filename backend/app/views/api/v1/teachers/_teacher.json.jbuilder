# frozen_string_literal: true

json.id teacher.id
json.employee_code teacher.employee_code
json.specialization teacher.specialization
json.hire_date teacher.hire_date
json.department_id teacher.department_id
json.user do
    json.partial! "api/v1/shared/user", user: teacher.user
end
