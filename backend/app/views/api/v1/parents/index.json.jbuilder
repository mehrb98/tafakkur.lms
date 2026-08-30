# frozen_string_literal: true

json.data @parents, partial: "api/v1/parents/parent", as: :parent
json.partial! "api/v1/shared/meta", paginated: @parents
