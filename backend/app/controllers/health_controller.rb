# frozen_string_literal: true

class HealthController < ActionController::API
    def show
        render json: { status: "ok", timestamp: Time.current.iso8601 }
    end

    def ready
        checks = {
            database: check_database,
            redis: check_redis
        }

        status = checks.values.all?("ok") ? :ok : :service_unavailable

        render json: { status: status == :ok ? "ready" : "not_ready", checks: checks }, status: status
    end

    private

    def check_database
        ActiveRecord::Base.connection.execute("SELECT 1")

        "ok"
    rescue StandardError
        "error"
    end

    def check_redis
        Sidekiq.redis(&:ping)

        "ok"
    rescue StandardError
        "error"
    end
end
