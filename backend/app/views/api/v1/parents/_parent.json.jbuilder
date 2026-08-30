# frozen_string_literal: true

json.id parent.id
json.occupation parent.occupation
json.user do
    json.partial! "api/v1/shared/user", user: parent.user
end
