# frozen_string_literal: true

module Auth
    class Logout
        include Interactor

        delegate :user, :raw_token, :access_payload, to: :context

        def call
            revoke_refresh_token
            denylist_access_token
            AuditLog.record!(user: user, action: "logout")
        end

        private

        def revoke_refresh_token
            return if raw_token.blank?

            record = RefreshToken.find_by_raw_token(raw_token)
            record.revoke! if record&.user_id == user.id && record.active?
        end

        def denylist_access_token
            return if access_payload.blank?

            JwtDenylist.revoke(access_payload["jti"], access_payload["exp"])
        end
    end
end
