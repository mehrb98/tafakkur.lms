# frozen_string_literal: true

# Encodes and decodes access tokens (HS256). Claims follow the SAD contract:
# sub (user id), school_id, role, jti, iat, exp.
class JwtService
    ALGORITHM = "HS256"
    ACCESS_TOKEN_TTL = 15.minutes

    class << self
        def encode(user)
            now = Time.current.to_i

            payload = {
                sub: user.id,
                school_id: user.school_id,
                role: user.role,
                jti: SecureRandom.uuid,
                iat: now,
                exp: now + ACCESS_TOKEN_TTL.to_i
            }

            [JWT.encode(payload, secret, ALGORITHM), payload]
        end

        def decode(token)
            JWT.decode(token, secret, true, algorithm: ALGORITHM).first
        rescue JWT::DecodeError
            nil
        end

        def secret
            ENV.fetch("JWT_SECRET")
        end
    end
end
