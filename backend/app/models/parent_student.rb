# frozen_string_literal: true

class ParentStudent < ApplicationRecord
    include TenantScoped

    belongs_to :parent
    belongs_to :student

    RELATIONSHIPS = %w[father mother guardian other].freeze

    validates :relationship, presence: true, inclusion: { in: RELATIONSHIPS }
    validates :student_id, uniqueness: { scope: :parent_id }
    validate :same_school_link

    private

    def same_school_link
        return if parent.nil? || student.nil?

        errors.add(:student_id, "must belong to the same school") if parent.school_id != student.school_id
    end
end
