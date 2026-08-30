# frozen_string_literal: true

module Auth
    class Login
        include Interactor

        delegate :email, :password, :remember_me, :ip_address, :user_agent, to: :context

        def call
            user = User.kept.find_by(email: email.to_s.downcase.strip)

            unless user&.valid_password?(password)
                audit_failed_login(user)
                context.fail!(error_code: "unauthorized", error_message: "Invalid email or password")
            end

            issue_tokens!(user)
            track_sign_in(user)
        end

        private

        def issue_tokens!(user)
            access_token, payload = JwtService.encode(user)
            raw_refresh, refresh_record = RefreshToken.issue!(
                user: user,
                remember_me: !remember_me.nil?,
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

            AuditLog.record!(user: user, action: "login", ip_address: ip_address)

            context.user = user
            context.access_token = access_token
            context.access_payload = payload
            context.refresh_token = raw_refresh
            context.refresh_record = refresh_record
        end

        def track_sign_in(user)
            user.update_columns(
                sign_in_count: user.sign_in_count + 1,
                last_sign_in_at: user.current_sign_in_at || Time.current,
                current_sign_in_at: Time.current,
                last_sign_in_ip: user.current_sign_in_ip,
                current_sign_in_ip: ip_address
            )
        end

        def device_name
            DeviceNameParser.parse(user_agent)
        end

        def audit_failed_login(user)
            AuditLog.record!(
                user: user,
                school: user&.school,
                action: "login_failed",
                metadata: { email: email },
                ip_address: ip_address
            )
        rescue ActiveRecord::RecordInvalid
            # Unknown email has no school context — nothing to audit.
            nil
        end
    end
end
