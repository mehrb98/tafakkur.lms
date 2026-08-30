# frozen_string_literal: true

json.data @teachers, partial: "api/v1/teachers/teacher", as: :teacher
json.partial! "api/v1/shared/meta", paginated: @teachers
