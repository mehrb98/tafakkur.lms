# frozen_string_literal: true

json.data do
    json.partial! "api/v1/parents/parent", parent: @parent
end
