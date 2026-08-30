# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
    frontend = ENV.fetch("FRONTEND_URL", "http://localhost:3000")
    allowed_origins = if Rails.env.development?
                          [frontend, "http://localhost:3000", "http://localhost:3001"].uniq
                      else
                          [frontend]
                      end

    allow do
        origins(*allowed_origins)

        resource "*",
                 headers: :any,
                 methods: %i[get post put patch delete options head],
                 expose: %w[Authorization],
                 credentials: true
    end
end
