# frozen_string_literal: true

json.data do
    json.access_token @access_token
    json.expires_in JwtService::ACCESS_TOKEN_TTL.to_i

    json.user do
        json.partial! "api/v1/shared/user", user: @user
    end
end
