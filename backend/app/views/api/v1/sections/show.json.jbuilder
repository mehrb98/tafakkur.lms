# frozen_string_literal: true

json.data do
    json.partial! "api/v1/sections/section", section: @section
end
