# frozen_string_literal: true

module Auth
    class ResetPassword
        include Interactor

        delegate :token, :password, :password_confirmation, :ip_address, to: :context

        def call
            user = User.with_reset_password_token(token.to_s)

            if user.nil? || !user.reset_password_period_valid?
                context.fail!(error_code: "validation_error", error_message: "Reset token is invalid or expired")
            end

            if password.to_s != password_confirmation.to_s
                context.fail!(
                    error_code: "validation_error",
                    error_message: "Record could not be saved",
                    error_details: [{ field: "password_confirmation", message: "doesn't match password" }]
                )
            end

            unless user.reset_password(password, password_confirmation)
                context.fail!(error_code: "validation_error", error_message: "Record could not be saved",
                              error_details: validation_details(user))
            end

            # Password change invalidates every session (SAD §8.5).
            user.refresh_tokens.active.find_each(&:revoke!)
            AuditLog.record!(user: user, action: "password_reset_completed", ip_address: ip_address)
            context.user = user
        end

        private

        def validation_details(user)
            user.errors.map { |error| { field: error.attribute.to_s, message: error.message } }
        end
    end
end
