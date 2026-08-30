# frozen_string_literal: true

json.data do
    json.partial! "api/v1/subject_assignments/subject_assignment", subject_assignment: @subject_assignment
end
