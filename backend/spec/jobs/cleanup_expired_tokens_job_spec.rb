# frozen_string_literal: true

require "rails_helper"

RSpec.describe CleanupExpiredTokensJob, type: :job do
    it "deletes tokens expired for more than 30 days and keeps the rest" do
        user = create(:user)
        old = create(:refresh_token, user: user, expires_at: 31.days.ago)
        recent = create(:refresh_token, user: user, expires_at: 1.day.ago)
        active = create(:refresh_token, user: user)

        described_class.perform_now

        expect(RefreshToken.exists?(old.id)).to be(false)
        expect(RefreshToken.exists?(recent.id)).to be(true)
        expect(RefreshToken.exists?(active.id)).to be(true)
    end
end
