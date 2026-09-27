# frozen_string_literal: true

# A pending "log in with QR code" request, Telegram-style: a signed-out browser
# shows a QR code, a signed-in phone scans and approves it, and the browser then
# collects a session for that phone's user.
#
# Two secrets are issued. The QR token is shown on screen and only lets a
# signed-in user scan/approve. The poll secret never leaves the browser that
# asked, so someone who photographs the QR code cannot collect the session.
# Only SHA-256 digests are stored.
class QrLoginRequest < ApplicationRecord
    TTL = 2.minutes
    STATUSES = %w[pending scanned approved declined consumed].freeze

    belongs_to :user, optional: true
    belongs_to :school, optional: true

    validates :token_digest, :poll_secret_digest, presence: true, uniqueness: true
    validates :status, inclusion: { in: STATUSES }
    validates :expires_at, presence: true

    # Returns [record, raw_qr_token, raw_poll_secret].
    def self.issue!(ip_address:, user_agent:)
        qr_token = SecureRandom.urlsafe_base64(32)
        poll_secret = SecureRandom.urlsafe_base64(32)

        record = create!(
            token_digest: digest(qr_token),
            poll_secret_digest: digest(poll_secret),
            device_name: DeviceNameParser.parse(user_agent),
            ip_address: ip_address,
            user_agent: user_agent,
            expires_at: TTL.from_now
        )
        [record, qr_token, poll_secret]
    end

    def self.digest(raw)
        Digest::SHA256.hexdigest(raw.to_s)
    end

    def self.find_by_qr_token(raw)
        raw.present? ? find_by(token_digest: digest(raw)) : nil
    end

    def self.find_by_poll_secret(raw)
        raw.present? ? find_by(poll_secret_digest: digest(raw)) : nil
    end

    def expired?
        expires_at.past?
    end

    # What the requesting browser sees while polling.
    def public_status
        return "expired" if expired? && %w[pending scanned approved].include?(status)

        status
    end

    def open_for?(user)
        return false if expired?
        return true if status == "pending"

        status == "scanned" && user_id == user.id
    end

    def mark_scanned!(user)
        update!(status: "scanned", user: user, school_id: user.school_id, scanned_at: Time.current)
    end

    def approve!(user, ip_address:)
        update!(
            status: "approved",
            user: user,
            school_id: user.school_id,
            approved_at: Time.current,
            approved_ip_address: ip_address
        )
    end

    def decline!
        update!(status: "declined")
    end

    # Atomically moves an approved request to consumed so a session is issued
    # at most once, even if the browser polls twice concurrently.
    def consume!
        self.class.where(id: id, status: "approved").update_all(status: "consumed", consumed_at: Time.current) == 1
    end
end
