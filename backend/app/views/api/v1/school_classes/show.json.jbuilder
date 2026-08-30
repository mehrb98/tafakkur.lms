# frozen_string_literal: true

json.data do
    json.partial! "api/v1/school_classes/school_class", school_class: @school_class
end
