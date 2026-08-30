# frozen_string_literal: true

require "rails_helper"

RSpec.describe Auth::Refresh, type: :interactor do
    let(:user) { create(:user) }

    it "rotates an active token and links the replacement" do
        raw, record = RefreshToken.issue!(user: user)

        result = described_class.call(raw_token: raw)

        expect(result).to be_success
        expect(result.access_token).to be_present
        expect(record.reload.revoked_at).to be_present
        expect(record.replaced_by).to eq(result.refresh_record)
    end

    it "fails for an unknown token" do
        result = described_class.call(raw_token: "unknown")
        expect(result).to be_failure
        expect(result.error_code).to eq("unauthorized")
    end

    it "revokes the whole family when a revoked token is replayed" do
        raw, record = RefreshToken.issue!(user: user)
        _other_raw, other = RefreshToken.issue!(user: user)
        record.revoke!

        result = described_class.call(raw_token: raw)

        expect(result).to be_failure
        expect(other.reload.revoked_at).to be_present
    end

    it "preserves the remember-me window across rotations" do
        raw, _record = RefreshToken.issue!(user: user, remember_me: true)

        result = described_class.call(raw_token: raw)

        expect(result.refresh_record.expires_at).to be_within(1.minute).of(30.days.from_now)
    end
end
