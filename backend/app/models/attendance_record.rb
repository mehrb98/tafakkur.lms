# frozen_string_literal: true

class AttendanceRecord < ApplicationRecord
    include TenantScoped

    belongs_to :student
    belongs_to :section
    belongs_to :recorded_by, class_name: "User"

    STATUSES = %w[present absent late excused].freeze

    validates :date, presence: true
    validates :status, presence: true, inclusion: { in: STATUSES }
    validates :student_id, uniqueness: { scope: %i[section_id date] }

    scope :on_date, ->(date) { where(date: date) }
    scope :for_section, ->(section_id) { where(section_id: section_id) }

    def absent?
        status == "absent"
    end
end
