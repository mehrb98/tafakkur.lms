# frozen_string_literal: true

require "rails_helper"

RSpec.describe RefreshToken, type: :model do
    let(:user) { create(:user) }

    describe ".issue!" do
        it "returns a raw token and persists only the digest" do
            raw, record = described_class.issue!(user: user)

            expect(raw).to be_present
            expect(record.token_digest).to eq(described_class.digest(raw))
            expect(record.token_digest).not_to eq(raw)
        end

        it "uses the 7 day TTL by default" do
            _raw, record = described_class.issue!(user: user)
            expect(record.expires_at).to be_within(1.minute).of(7.days.from_now)
        end

        it "uses the 30 day TTL with remember_me" do
            _raw, record = described_class.issue!(user: user, remember_me: true)
            expect(record.expires_at).to be_within(1.minute).of(30.days.from_now)
        end
    end

    describe "#revoke!" do
        it "marks the token revoked and records the replacement" do
            _raw, record = described_class.issue!(user: user)
            _raw2, replacement = described_class.issue!(user: user)

            record.revoke!(replaced_by: replacement)

            expect(record.reload.revoked_at).to be_present
            expect(record.replaced_by).to eq(replacement)
            expect(record).not_to be_active
        end
    end

    describe ".active scope" do
        it "excludes revoked and expired tokens" do
            _raw, active = described_class.issue!(user: user)
            _raw, revoked = described_class.issue!(user: user)
            revoked.revoke!
            expired = create(:refresh_token, user: user, expires_at: 1.hour.ago)

            expect(described_class.active).to include(active)
            expect(described_class.active).not_to include(revoked, expired)
        end
    end
end
