# frozen_string_literal: true

module Auth
    class RequestPasswordReset
        include Interactor

        delegate :email, :ip_address, to: :context

        # Always succeeds from the caller's perspective to prevent email
        # enumeration (SAD api-reference §2).
        def call
            user = User.kept.find_by(email: email.to_s.downcase.strip)
            return if user.nil?

            raw_token = user.send(:set_reset_password_token)
            SendPasswordResetJob.perform_later(user.id, raw_token)
            AuditLog.record!(user: user, action: "password_reset_requested", ip_address: ip_address)
        end
    end
end
