# frozen_string_literal: true

# The httpOnly refresh-token cookie, scoped to the auth endpoints.
module RefreshCookie
    extend ActiveSupport::Concern

    included do
        include ActionController::Cookies
    end

    REFRESH_COOKIE = :refresh_token

    private

    def set_refresh_cookie(raw_token, expires_at)
        cookies[REFRESH_COOKIE] = {
            value: raw_token,
            httponly: true,
            secure: Rails.env.production?,
            same_site: :lax,
            path: refresh_cookie_path,
            expires: expires_at
        }
    end

    def delete_refresh_cookie
        cookies.delete(REFRESH_COOKIE, path: refresh_cookie_path)
    end

    def refresh_cookie_path
        "/api/v1/auth"
    end
end
