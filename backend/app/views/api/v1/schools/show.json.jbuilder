# frozen_string_literal: true

json.data do
    json.id @school.id
    json.name @school.name
    json.slug @school.slug
    json.domain @school.domain
    json.timezone @school.timezone
    json.locale @school.locale
    json.settings @school.settings
    json.subscription_status @school.subscription_status
end
