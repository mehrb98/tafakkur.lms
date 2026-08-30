# frozen_string_literal: true

json.data do
    json.partial! "api/v1/semesters/semester", semester: @semester
end
