# frozen_string_literal: true

module Rack
    class Attack
        ### General throttle: 300 requests per 5 minutes per IP
        throttle("req/ip", limit: 300, period: 5.minutes) do |req|
            next if req.path.start_with?("/health", "/api/openapi")
            next if req.path == "/api" || (req.path.start_with?("/api/") && !req.path.start_with?("/api/v1/"))

            req.ip
        end

        ### Login throttles: 5 attempts per minute per email + per IP
        throttle("login/email", limit: 5, period: 1.minute) do |req|
            if req.path == "/api/v1/auth/login" && req.post?
                begin
                    body = JSON.parse(req.body.read)
                    req.body.rewind
                    body["email"].to_s.downcase.presence
                rescue JSON::ParserError
                    nil
                end
            end
        end

        throttle("login/ip", limit: 10, period: 1.minute) do |req|
            req.ip if req.path == "/api/v1/auth/login" && req.post?
        end

        ### Password reset: 5 per 15 minutes per IP
        throttle("password_reset/ip", limit: 5, period: 15.minutes) do |req|
            req.ip if req.path == "/api/v1/auth/password" && req.post?
        end

        ### QR login: creating codes and polling for approval
        throttle("qr_login/create/ip", limit: 10, period: 1.minute) do |req|
            req.ip if req.path == "/api/v1/auth/qr" && req.post?
        end

        throttle("qr_login/poll/ip", limit: 90, period: 1.minute) do |req|
            req.ip if req.path == "/api/v1/auth/qr/poll" && req.post?
        end

        self.throttled_responder = lambda do |_request|
            body = {
                error: {
                    code: "rate_limit_exceeded",
                    message: "Too many requests. Please try again later.",
                    details: []
                }
            }.to_json

            [429, { "Content-Type" => "application/json" }, [body]]
        end
    end
end

Rack::Attack.enabled = !Rails.env.test?
