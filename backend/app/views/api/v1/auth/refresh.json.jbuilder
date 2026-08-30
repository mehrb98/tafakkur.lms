# frozen_string_literal: true

json.data do
    json.access_token @access_token
    json.expires_in JwtService::ACCESS_TOKEN_TTL.to_i
end
