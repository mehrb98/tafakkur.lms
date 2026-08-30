# frozen_string_literal: true

module AuthHelpers
    def authenticated_headers(user)
        token, _payload = JwtService.encode(user)

        { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" }
    end

    def json_body
        JSON.parse(response.body)
    end
end
