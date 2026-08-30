# frozen_string_literal: true

json.data @subject_assignments,
          partial: "api/v1/subject_assignments/subject_assignment",
          as: :subject_assignment
json.partial! "api/v1/shared/meta", paginated: @subject_assignments
