# frozen_string_literal: true

json.data @departments, partial: "api/v1/departments/department", as: :department
json.partial! "api/v1/shared/meta", paginated: @departments
