# frozen_string_literal: true

json.data do
    json.partial! "api/v1/academic_years/academic_year", academic_year: @academic_year
end
