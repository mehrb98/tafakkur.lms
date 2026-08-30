# frozen_string_literal: true

json.data do
    json.partial! "api/v1/teachers/teacher", teacher: @teacher
end
