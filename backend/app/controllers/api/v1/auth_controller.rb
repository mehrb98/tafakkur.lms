# frozen_string_literal: true

module Api
    module V1
        class AuthController < BaseController
            include RefreshCookie

            skip_before_action :authenticate_request!,
                               only: %i[login refresh request_password_reset reset_password confirm_email]
            skip_before_action :set_current_tenant,
                               only: %i[login refresh request_password_reset reset_password confirm_email]

            def login
                result = Auth::Login.call(
                    email: params.require(:email),
                    password: params.require(:password),
                    remember_me: params[:remember_me],
                    ip_address: request.remote_ip,
                    user_agent: request.user_agent
                )
                return render_interactor_error(result) if result.failure?

                set_refresh_cookie(result.refresh_token, result.refresh_record.expires_at)
                @user = result.user
                @access_token = result.access_token
                render :login, status: :created
            end

            def refresh
                result = Auth::Refresh.call(
                    raw_token: cookies[REFRESH_COOKIE],
                    ip_address: request.remote_ip,
                    user_agent: request.user_agent
                )
                if result.failure?
                    delete_refresh_cookie
                    return render_interactor_error(result)
                end

                set_refresh_cookie(result.refresh_token, result.refresh_record.expires_at)
                @access_token = result.access_token
                render :refresh
            end

            def logout
                Auth::Logout.call(
                    user: current_user,
                    raw_token: cookies[REFRESH_COOKIE],
                    access_payload: current_access_payload
                )
                delete_refresh_cookie
                head :no_content
            end

            def logout_all
                Auth::LogoutAll.call(user: current_user, access_payload: current_access_payload)
                delete_refresh_cookie
                head :no_content
            end

            def sessions
                @sessions = current_user.device_sessions.active.order(last_active_at: :desc)
                @current_refresh_digest = current_refresh_digest
                render :sessions
            end

            def revoke_session
                session = current_user.device_sessions.find(params.expect(:id))
                session.refresh_token.revoke!
                AuditLog.record!(user: current_user, action: "device_session_revoked", auditable: session)
                head :no_content
            end

            def request_password_reset
                Auth::RequestPasswordReset.call(
                    email: params.require(:email),
                    ip_address: request.remote_ip
                )
                render json: { data: { message: "If the email exists, a reset link has been sent." } }
            end

            def reset_password
                result = Auth::ResetPassword.call(
                    token: params.require(:token),
                    password: params.require(:password),
                    password_confirmation: params[:password_confirmation],
                    ip_address: request.remote_ip
                )
                return render_interactor_error(result) if result.failure?

                render json: { data: { message: "Password updated successfully. All sessions revoked." } }
            end

            def confirm_email
                result = Auth::VerifyEmail.call(token: params.require(:token))
                return render_interactor_error(result) if result.failure?

                render json: { data: { message: "Email verified successfully." } }
            end

            private

            def current_access_payload
                JwtService.decode(bearer_token)
            end

            def current_refresh_digest
                raw = cookies[REFRESH_COOKIE]
                raw.present? ? RefreshToken.digest(raw) : nil
            end
        end
    end
end
