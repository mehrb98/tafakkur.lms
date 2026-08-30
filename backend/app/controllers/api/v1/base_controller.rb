# frozen_string_literal: true

module Api
    module V1
        class BaseController < ActionController::API
            include Pundit::Authorization

            before_action :authenticate_request!
            before_action :set_current_tenant

            rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
            rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
            rescue_from ActionController::ParameterMissing, with: :render_bad_request

            attr_reader :current_user

            private

            def authenticate_request!
                token = bearer_token
                return render_unauthorized("Missing access token") if token.blank?

                payload = JwtService.decode(token)
                return render_unauthorized("Invalid or expired token") if payload.nil?
                return render_unauthorized("Token has been revoked") if JwtDenylist.revoked?(payload["jti"])

                @current_user = User.kept.find_by(id: payload["sub"])
                render_unauthorized("Invalid or expired token") if @current_user.nil?
            end

            def set_current_tenant
                return if @current_user.nil?

                Current.user = @current_user
                Current.school = @current_user.school
                Current.request_id = request.request_id
            end

            def current_school
                Current.school
            end

            def bearer_token
                header = request.headers["Authorization"]
                header&.match(/\ABearer (.+)\z/)&.captures&.first
            end

            def paginate(scope)
                limit = params.fetch(:limit, 25).to_i.clamp(1, 100)
                scope.page(params.fetch(:page, 1)).per(limit)
            end

            def render_interactor_error(result)
                status = case result.error_code
                         when "unauthorized" then :unauthorized
                         when "not_found" then :not_found
                         when "forbidden" then :forbidden
                         else :unprocessable_entity
                         end
                render_error(
                    code: result.error_code || "validation_error",
                    message: result.error_message || "Request could not be processed",
                    details: result.error_details || [],
                    status: status
                )
            end

            def render_error(code:, message:, status:, details: [])
                render json: {
                    error: { code: code, message: message, details: details }
                }, status: status
            end

            def render_validation_errors(errors)
                details = errors.map do |error|
                    { field: error.attribute.to_s, message: error.message }
                end

                render_error(
                    code: "validation_error",
                    message: "Record could not be saved",
                    details: details,
                    status: :unprocessable_entity
                )
            end

            def render_unauthorized(message = "Unauthorized")
                render_error(code: "unauthorized", message: message, status: :unauthorized)
            end

            def render_forbidden(_exception = nil)
                render_error(
                    code: "forbidden",
                    message: "You are not authorized to perform this action",
                    status: :forbidden
                )
            end

            def render_not_found(_exception = nil)
                render_error(code: "not_found", message: "Record not found", status: :not_found)
            end

            def render_bad_request(exception)
                render_error(code: "bad_request", message: exception.message, status: :bad_request)
            end
        end
    end
end
