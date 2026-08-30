# frozen_string_literal: true

Rswag::Ui.configure do |c|
    c.openapi_endpoint "/api/openapi/v1/swagger.yaml", "Tafakkur LMS API v1"
    c.config_object["deepLinking"] = true
    c.config_object["displayRequestDuration"] = true
    c.config_object["persistAuthorization"] = true
    c.config_object["tryItOutEnabled"] = true
end
