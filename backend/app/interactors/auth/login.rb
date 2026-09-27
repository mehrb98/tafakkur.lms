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
        end

        private

        def issue_tokens!(user)
            session = SessionIssuer.call(
                user: user,
                remember_me: !remember_me.nil?,
                ip_address: ip_address,
                user_agent: user_agent
            )

            context.user = user
            context.access_token = session.access_token
            context.access_payload = session.access_payload
            context.refresh_token = session.refresh_token
            context.refresh_record = session.refresh_record
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
