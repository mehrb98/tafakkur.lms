# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
    subject(:user) { build(:user) }

    describe "associations" do
        it { is_expected.to belong_to(:school) }
        it { is_expected.to have_many(:refresh_tokens).dependent(:destroy) }
        it { is_expected.to have_many(:device_sessions).dependent(:destroy) }
    end

    describe "validations" do
        it { is_expected.to validate_presence_of(:email) }
        it { is_expected.to validate_presence_of(:first_name) }
        it { is_expected.to validate_presence_of(:last_name) }

        it "requires a password of at least 12 characters" do
            user.password = "short"
            expect(user).not_to be_valid
            expect(user.errors[:password]).to be_present
        end

        it "enforces email uniqueness per school" do
            existing = create(:user)
            duplicate = build(:user, school: existing.school, email: existing.email)
            expect(duplicate).not_to be_valid
        end

        it "allows the same email at a different school" do
            existing = create(:user)
            other = build(:user, school: create(:school), email: existing.email)
            expect(other).to be_valid
        end

        it "rejects invalid roles" do
            expect { user.role = "superuser" }.not_to raise_error
            expect(user).not_to be_valid
        end
    end

    describe "#normalize_email" do
        it "downcases and strips email before validation" do
            user.email = "  Admin@School.COM "
            user.valid?
            expect(user.email).to eq("admin@school.com")
        end
    end

    describe "soft delete" do
        it "excludes discarded users from kept scope" do
            active = create(:user)
            discarded = create(:user, school: active.school)
            discarded.discard

            expect(described_class.kept).to include(active)
            expect(described_class.kept).not_to include(discarded)
        end
    end
end
