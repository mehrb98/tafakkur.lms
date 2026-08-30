# frozen_string_literal: true

module Auth
    class VerifyEmail
        include Interactor

        delegate :token, to: :context

        def call
            user = User.confirm_by_token(token.to_s)

            if user.errors.any?
                context.fail!(
                    error_code: "validation_error",
                    error_message: "Confirmation token is invalid or expired"
                )
            end

            AuditLog.record!(user: user, action: "email_verified")
            context.user = user
        end
    end
end
