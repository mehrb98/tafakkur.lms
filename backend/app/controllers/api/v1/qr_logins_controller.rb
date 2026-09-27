# frozen_string_literal: true

module Api
    module V1
        # Telegram-style QR login. A signed-out browser creates a request and shows
        # the QR token as a QR code; a signed-in phone scans and approves it; the
        # browser polls with its poll secret and receives a session once approved.
        class QrLoginsController < BaseController
            include RefreshCookie

            PUBLIC_ACTIONS = %i[create poll].freeze

            skip_before_action :authenticate_request!, only: PUBLIC_ACTIONS
            skip_before_action :set_current_tenant, only: PUBLIC_ACTIONS

            before_action :load_request_for_phone, only: %i[scan approve decline]

            def create
                record, qr_token, poll_secret = QrLoginRequest.issue!(
                    ip_address: request.remote_ip,
                    user_agent: request.user_agent
                )

                render json: {
                    data: {
                        qr_token: qr_token,
                        poll_secret: poll_secret,
                        expires_at: record.expires_at.iso8601,
                        expires_in: QrLoginRequest::TTL.to_i
                    }
                }, status: :created
            end

            def poll
                record = QrLoginRequest.find_by_poll_secret(params.require(:poll_secret))
                return render_not_found if record.nil?
                return render json: { data: { status: record.public_status } } unless record.status == "approved"

                user = record.user
                unless !record.expired? && user&.kept? && record.consume!
                    return render json: { data: { status: record.reload.public_status } }
                end

                session = SessionIssuer.call(
                    user: user,
                    remember_me: true,
                    ip_address: request.remote_ip,
                    user_agent: request.user_agent,
                    audit_metadata: { method: "qr", qr_login_request_id: record.id }
                )
                set_refresh_cookie(session.refresh_token, session.refresh_record.expires_at)
                @user = user
                @access_token = session.access_token
                render "api/v1/auth/login", status: :created
            end

            def scan
                @qr_request.mark_scanned!(current_user) if @qr_request.status == "pending"

                render json: {
                    data: {
                        device_name: @qr_request.device_name,
                        ip_address: @qr_request.ip_address&.to_s,
                        requested_at: @qr_request.created_at.iso8601,
                        expires_at: @qr_request.expires_at.iso8601
                    }
                }
            end

            def approve
                @qr_request.approve!(current_user, ip_address: request.remote_ip)
                AuditLog.record!(
                    user: current_user,
                    action: "qr_login_approved",
                    auditable: @qr_request,
                    metadata: { device_name: @qr_request.device_name },
                    ip_address: request.remote_ip
                )
                render json: { data: { status: "approved" } }
            end

            def decline
                @qr_request.decline!
                render json: { data: { status: "declined" } }
            end

            private

            def load_request_for_phone
                @qr_request = QrLoginRequest.find_by_qr_token(params.require(:qr_token))
                return render_not_found if @qr_request.nil?
                return if @qr_request.open_for?(current_user)

                render_error(
                    code: "qr_login_unavailable",
                    message: "This QR code has expired or was already used. Refresh it on the computer and scan again.",
                    status: :unprocessable_entity
                )
            end
        end
    end
end
