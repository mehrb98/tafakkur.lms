# frozen_string_literal: true

Rails.application.configure do
    config.lograge.enabled = Rails.env.production? || Rails.env.staging?
    config.lograge.formatter = Lograge::Formatters::Json.new

    config.lograge.custom_payload do |controller|
        {
            request_id: controller.request.request_id,
            user_id: controller.respond_to?(:current_user, true) ? controller.send(:current_user)&.id : nil,
            school_id: Current.school&.id
        }
    end
end
