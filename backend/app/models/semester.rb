# frozen_string_literal: true

class Semester < ApplicationRecord
    include TenantScoped
    include Discardable

    belongs_to :academic_year

    validates :name, presence: true, uniqueness: { scope: :academic_year_id }
    validates :start_date, :end_date, presence: true
    validate :end_after_start
    validate :within_academic_year

    private

    def end_after_start
        return if start_date.blank? || end_date.blank?

        errors.add(:end_date, "must be after start date") if end_date <= start_date
    end

    def within_academic_year
        return if academic_year.nil? || start_date.blank? || end_date.blank?

        return unless start_date < academic_year.start_date || end_date > academic_year.end_date

        errors.add(:base, "semester dates must fall within the academic year")
    end
end
