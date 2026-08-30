# frozen_string_literal: true

json.data @academic_years, partial: "api/v1/academic_years/academic_year", as: :academic_year
json.partial! "api/v1/shared/meta", paginated: @academic_years
