# frozen_string_literal: true

class AcademicYear < ApplicationRecord
    include TenantScoped
    include Discardable

    has_many :semesters, dependent: :destroy

    validates :name, presence: true, uniqueness: { scope: :school_id }
    validates :start_date, :end_date, presence: true
    validate :end_after_start

    scope :current, -> { where(is_current: true) }

    private

    def end_after_start
        return if start_date.blank? || end_date.blank?

        errors.add(:end_date, "must be after start date") if end_date <= start_date
    end
end
