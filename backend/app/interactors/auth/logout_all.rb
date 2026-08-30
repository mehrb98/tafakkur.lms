# frozen_string_literal: true

module Auth
    class LogoutAll
        include Interactor

        delegate :user, :access_payload, to: :context

        def call
            user.refresh_tokens.active.find_each(&:revoke!)
            JwtDenylist.revoke(access_payload["jti"], access_payload["exp"]) if access_payload.present?
            AuditLog.record!(user: user, action: "logout_all_devices")
        end
    end
end
