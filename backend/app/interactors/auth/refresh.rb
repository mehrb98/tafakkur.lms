# frozen_string_literal: true

module Auth
    class Refresh
        include Interactor

        delegate :raw_token, :ip_address, :user_agent, to: :context

        def call
            record = RefreshToken.find_by_raw_token(raw_token.to_s)
            context.fail!(error_code: "unauthorized", error_message: "Invalid refresh token") if record.nil?

            handle_reuse!(record) unless record.active?

            rotate!(record)
        end

        private

        # A revoked token being presented again means it was stolen or replayed.
        # Revoke every session for the user (SAD §8.4).
        def handle_reuse!(record)
            if record.revoked_at.present?
                record.user.refresh_tokens.active.find_each(&:revoke!)
                AuditLog.record!(
                    user: record.user,
                    action: "refresh_token_reuse_detected",
                    ip_address: ip_address
                )
            end
            context.fail!(error_code: "unauthorized", error_message: "Invalid refresh token")
        end

        def rotate!(record)
            user = record.user

            ActiveRecord::Base.transaction do
                raw_refresh, new_record = RefreshToken.issue!(
                    user: user,
                    remember_me: remember_me_window?(record),
                    device_name: record.device_name,
                    ip_address: ip_address,
                    user_agent: user_agent || record.user_agent
                )
                record.revoke!(replaced_by: new_record)
                migrate_device_session(record, new_record)

                context.refresh_token = raw_refresh
                context.refresh_record = new_record
            end

            context.user = user
            context.access_token, context.access_payload = JwtService.encode(user)
        end

        # Preserve the original session window: tokens issued for ~30 days keep
        # rotating with the remember-me TTL.
        def remember_me_window?(record)
            (record.expires_at - record.created_at) > RefreshToken::DEFAULT_TTL + 1.day
        end

        def migrate_device_session(old_record, new_record)
            session = old_record.device_session
            return if session.nil?

            session.update!(refresh_token: new_record, last_active_at: Time.current)
        end
    end
end
