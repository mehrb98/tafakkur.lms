# frozen_string_literal: true

# In-memory denylist for tests so specs never require a running Redis.
RSpec.configure do |config|
    config.before do
        denylist = Set.new

        allow(JwtDenylist).to receive(:revoke) do |jti, _expires_at|
            denylist << jti
        end

        allow(JwtDenylist).to receive(:revoked?) do |jti|
            denylist.include?(jti)
        end
    end
end
