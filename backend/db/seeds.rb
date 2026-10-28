# frozen_string_literal: true

require "faker"
require_relative "seeds/demo_school"

abort "Refusing to seed a production database." if Rails.env.production?

Rails.logger.debug "Seeding Tafakkur LMS demo data..."

ActiveRecord::Base.transaction do
    Seeds::DemoSchool.call
end

Rails.logger.debug "Done. Login: admin@demo.tafakkur.local / #{Seeds::DemoSchool::DEMO_PASSWORD}"
