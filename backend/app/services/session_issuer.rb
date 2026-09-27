# frozen_string_literal: true

# Issues an access token plus a rotating refresh token and device session for a
# user. Shared by password login and QR login.
class SessionIssuer
    Result = Struct.new(:access_token, :access_payload, :refresh_token, :refresh_record, keyword_init: true)

    def self.call(user:, remember_me:, ip_address:, user_agent:, audit_metadata: {})
        device_name = DeviceNameParser.parse(user_agent)
        access_token, payload = JwtService.encode(user)
        raw_refresh, refresh_record = RefreshToken.issue!(
            user: user,
            remember_me: remember_me,
            device_name: device_name,
            ip_address: ip_address,
            user_agent: user_agent
        )

        DeviceSession.create!(
            user: user,
            refresh_token: refresh_record,
            school_id: user.school_id,
            device_name: device_name,
            ip_address: ip_address,
            last_active_at: Time.current
        )

        AuditLog.record!(user: user, action: "login", ip_address: ip_address, metadata: audit_metadata)
        track_sign_in(user, ip_address)

        Result.new(
            access_token: access_token,
            access_payload: payload,
            refresh_token: raw_refresh,
            refresh_record: refresh_record
        )
    end

    def self.track_sign_in(user, ip_address)
        user.update_columns(
            sign_in_count: user.sign_in_count + 1,
            last_sign_in_at: user.current_sign_in_at || Time.current,
            current_sign_in_at: Time.current,
            last_sign_in_ip: user.current_sign_in_ip,
            current_sign_in_ip: ip_address
        )
    end
    private_class_method :track_sign_in
end
