# frozen_string_literal: true

FactoryBot.define do
    factory :refresh_token do
        user
        school { user.school }
        token_digest { RefreshToken.digest(SecureRandom.urlsafe_base64(64)) }
        device_name { "Chrome on macOS" }
        expires_at { 7.days.from_now }
    end
end
