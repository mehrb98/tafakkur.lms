# frozen_string_literal: true

json.data @sessions do |session|
    json.id session.id
    json.device_name session.device_name
    json.ip_address session.ip_address&.to_s
    json.last_active_at session.last_active_at.iso8601
    json.is_current session.refresh_token.token_digest == @current_refresh_digest
end
