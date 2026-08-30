# frozen_string_literal: true

json.data @grades, partial: "api/v1/grades/grade", as: :grade
json.partial! "api/v1/shared/meta", paginated: @grades
