# frozen_string_literal: true

class Department < ApplicationRecord
    include TenantScoped
    include Discardable

    belongs_to :parent, class_name: "Department", optional: true
    has_many :children, class_name: "Department", foreign_key: :parent_id,
                        inverse_of: :parent, dependent: :nullify

    validates :name, presence: true, uniqueness: { scope: :school_id }
    validate :parent_in_same_school
    validate :no_self_parent

    private

    def parent_in_same_school
        return if parent_id.blank?

        # Bypass the tenant default scope: a cross-school parent must be
        # rejected explicitly, not silently treated as missing.
        parent_record = Department.unscoped.find_by(id: parent_id)
        return unless parent_record.nil? || parent_record.school_id != school_id

        errors.add(:parent_id, "must belong to the same school")
    end

    def no_self_parent
        errors.add(:parent_id, "cannot be itself") if parent_id.present? && parent_id == id
    end
end
