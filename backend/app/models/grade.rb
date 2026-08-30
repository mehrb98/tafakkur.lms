# frozen_string_literal: true

class Grade < ApplicationRecord
    include TenantScoped

    belongs_to :student
    belongs_to :subject
    belongs_to :semester
    belongs_to :teacher

    GRADE_TYPES = %w[assignment quiz exam project participation final].freeze

    validates :grade_type, presence: true, inclusion: { in: GRADE_TYPES }
    validates :value, presence: true,
                      numericality: { greater_than_or_equal_to: 0 }
    validates :max_value, presence: true, numericality: { greater_than: 0 }
    validates :graded_on, presence: true
    validate :value_within_max

    private

    def value_within_max
        return if value.blank? || max_value.blank?

        errors.add(:value, "must be less than or equal to max value") if value > max_value
    end
end
