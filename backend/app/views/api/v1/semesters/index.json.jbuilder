# frozen_string_literal: true

json.data @semesters, partial: "api/v1/semesters/semester", as: :semester
json.partial! "api/v1/shared/meta", paginated: @semesters
