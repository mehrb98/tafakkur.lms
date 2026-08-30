# frozen_string_literal: true

class Enrollment < ApplicationRecord
    include TenantScoped

    belongs_to :student
    belongs_to :section
    belongs_to :academic_year

    STATUSES = %w[active transferred withdrawn completed].freeze

    validates :status, inclusion: { in: STATUSES }
    validates :enrolled_on, presence: true
    validates :student_id, uniqueness: {
        scope: :academic_year_id,
        conditions: -> { where(status: "active") },
        message: "is already enrolled in a class for this academic year"
    }, if: -> { status == "active" }
    validate :section_capacity, on: :create
    validate :section_in_academic_year

    scope :active, -> { where(status: "active") }

    private

    def section_capacity
        return if section.nil? || status != "active"

        errors.add(:section_id, "is at full capacity") if section.full?
    end

    def section_in_academic_year
        return if section.nil? || academic_year.nil?

        return if section.school_class.academic_year_id == academic_year_id

        errors.add(:section_id, "does not belong to the given academic year")
    end
end
