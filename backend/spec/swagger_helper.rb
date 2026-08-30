# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
    config.openapi_root = Rails.root.join("swagger").to_s

    config.openapi_specs = {
        "v1/swagger.yaml" => {
            openapi: "3.0.3",
            info: {
                title: "Tafakkur LMS API",
                version: "v1"
            },
            paths: {},
            servers: [
                { url: "/", description: "Current host" }
            ],
            components: {
                securitySchemes: {
                    bearerAuth: {
                        type: :http,
                        scheme: :bearer,
                        bearerFormat: "JWT"
                    }
                }
            },
            security: [{ bearerAuth: [] }]
        }
    }

    config.openapi_format = :yaml
end
