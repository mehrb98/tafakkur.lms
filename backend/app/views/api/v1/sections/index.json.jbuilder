# frozen_string_literal: true

json.data @sections, partial: "api/v1/sections/section", as: :section
json.partial! "api/v1/shared/meta", paginated: @sections
