# frozen_string_literal: true

json.data @subjects, partial: "api/v1/subjects/subject", as: :subject
json.partial! "api/v1/shared/meta", paginated: @subjects
