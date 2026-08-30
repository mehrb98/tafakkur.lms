# frozen_string_literal: true

json.data @school_classes, partial: "api/v1/school_classes/school_class", as: :school_class
json.partial! "api/v1/shared/meta", paginated: @school_classes
