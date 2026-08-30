# frozen_string_literal: true

# Redis-backed denylist for revoked access-token jti claims. Entries expire
# with the token itself so the set never grows unbounded.
class JwtDenylist
    KEY_PREFIX = "jwt:denylist:"

    class << self
        def revoke(jti, expires_at)
            ttl = (expires_at - Time.current.to_i).to_i

            return if ttl <= 0

            redis { |conn| conn.call("SETEX", "#{KEY_PREFIX}#{jti}", ttl, "1") }
        end

        def revoked?(jti)
            return false if jti.blank?

            redis { |conn| conn.call("EXISTS", "#{KEY_PREFIX}#{jti}") }.to_i.positive?
        end

        private

        def redis(&)
            Sidekiq.redis(&)
        end
    end
end
