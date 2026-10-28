# frozen_string_literal: true

class Report < ApplicationRecord
    include TenantScoped

    belongs_to :requested_by, class_name: "User"

    REPORT_TYPES = %w[attendance grades enrollment custom].freeze
    STATUSES = %w[pending processing completed failed].freeze

    validates :report_type, presence: true, inclusion: { in: REPORT_TYPES }
    validates :status, inclusion: { in: STATUSES }

    scope :completed, -> { where(status: "completed") }
end
