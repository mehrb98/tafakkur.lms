# frozen_string_literal: true

class RefreshToken < ApplicationRecord
    belongs_to :user
    belongs_to :school
    belongs_to :replaced_by, class_name: "RefreshToken", optional: true
    has_one :device_session, dependent: :destroy

    DEFAULT_TTL = 7.days
    REMEMBER_ME_TTL = 30.days

    validates :token_digest, presence: true, uniqueness: true
    validates :expires_at, presence: true

    scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

    def self.digest(raw_token)
        Digest::SHA256.hexdigest(raw_token)
    end

    # Issues a new refresh token. Returns [raw_token, record]; only the digest
    # is persisted so a database leak never exposes usable tokens.
    def self.issue!(user:, remember_me: false, device_name: nil, ip_address: nil, user_agent: nil)
        raw = SecureRandom.urlsafe_base64(64)
        ttl = remember_me ? REMEMBER_ME_TTL : DEFAULT_TTL

        record = create!(
            user: user,
            school_id: user.school_id,
            token_digest: digest(raw),
            device_name: device_name,
            ip_address: ip_address,
            user_agent: user_agent,
            expires_at: ttl.from_now
        )
        [raw, record]
    end

    def self.find_by_raw_token(raw_token)
        find_by(token_digest: digest(raw_token))
    end

    def active?
        revoked_at.nil? && expires_at.future?
    end

    def revoke!(replaced_by: nil)
        update!(revoked_at: Time.current, replaced_by: replaced_by)
    end
end
