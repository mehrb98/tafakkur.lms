# frozen_string_literal: true

class Section < ApplicationRecord
    include TenantScoped
    include Discardable

    belongs_to :school_class
    belongs_to :homeroom_teacher, class_name: "Teacher", optional: true
    has_many :enrollments, dependent: :destroy
    has_many :students, through: :enrollments
    has_many :subject_assignments, dependent: :destroy

    validates :name, presence: true, uniqueness: { scope: :school_class_id }
    validates :capacity, numericality: { only_integer: true, greater_than: 0 }

    def active_enrollments_count
        enrollments.where(status: "active").count
    end

    def full?
        active_enrollments_count >= capacity
    end
end
